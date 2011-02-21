#lang racket/base
(require "typed-structs.rkt")
(provide parse)

(define (parse exp)
  (cond
    [(self-evaluating? exp)
     (make-Constant exp)]
    [(quoted? exp)
     (make-Quote (text-of-quotation exp))]
    [(variable? exp)
     (make-Var exp)]      
    [(assignment? exp)
     (make-Assign (assignment-variable exp)
                  (parse (assignment-value exp)))]
    [(definition? exp)
     (make-Def (definition-variable exp)
               (parse (definition-value exp)))]
    [(if? exp)
     (make-Branch (parse (if-predicate exp))
                  (parse (if-consequent exp))
                  (parse (if-alternative exp)))]
    [(lambda? exp)
     (make-Lam (lambda-parameters exp)
               (map parse (lambda-body exp)))]
    [(begin? exp)
     (make-Seq (map parse (begin-actions exp)))]
    
    [(application? exp)
     (make-App (parse (operator exp))
               (map parse (operands exp)))]
    
    [else
     (error 'compile "Unknown expression type ~e" exp)]))



;; expression selectors

(define (self-evaluating? exp)
  (cond
    [(number? exp) #t]
    [(string? exp) #t]
    [else #f]))

(define (variable? exp) (symbol? exp))

(define (quoted? exp) (tagged-list? exp 'quote))
(define (text-of-quotation exp) (cadr exp))


(define (tagged-list? exp tag)
  (if (pair? exp)
      (eq? (car exp) tag)
      #f))

(define (assignment? exp)
  (tagged-list? exp 'set!))
(define (assignment-variable exp) (cadr exp))
(define (assignment-value exp) (caddr exp))

(define (definition? exp)
  (tagged-list? exp 'define))
(define (definition-variable exp)
  (if (symbol? (cadr exp))
      (cadr exp)
      (caadr exp)))
(define (definition-value exp)
  (if (symbol? (cadr exp))
      (caddr exp)
      (make-lambda (cdadr exp)
                   (cddr exp))))

(define (lambda? exp)
  (tagged-list? exp 'lambda))
(define (lambda-parameters exp) (cadr exp))
(define (lambda-body exp) (cddr exp))

(define (make-lambda parameters body)
  (cons 'lambda (cons parameters body)))

(define (if? exp)
  (tagged-list? exp 'if))
(define (if-predicate exp)
  (cadr exp))
(define (if-consequent exp)
  (caddr exp))
(define (if-alternative exp)
  (if (not (null? (cdddr exp)))
      (cadddr exp)
      'false))

(define (begin? exp)
  (tagged-list? exp 'begin))
(define (begin-actions exp) (cdr exp))

(define (application? exp) (pair? exp))
(define (operator exp) (car exp))
(define (operands exp) (cdr exp))