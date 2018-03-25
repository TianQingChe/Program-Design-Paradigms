#lang racket

(require racket/sandbox)
(require rackunit)
(require rackunit/text-ui)
(require "q1.rkt")

;; Test case utilities

(define TIME-LIMIT-S 10)
(define MEMORY-LIMIT-MB 128)

(define-syntax limited-test-case
  (syntax-rules ()
    ((_ name body ...)
     (test-case name
                (with-limits TIME-LIMIT-S
                             MEMORY-LIMIT-MB
                             body ...)))))

;; Defining constants

(define BLOCK-1
  (block (var "x5")
         (block (var "z")
                (call (op "*")
                      (list (var "x") (var "y")))
                (op "+"))
         (call (op "*")
               (list (var "x6") (var "x7")))))



;; my-member? : X SetOf<X> -> Boolean
;; strategy: HO Function Combination
(define (my-member? x set1)
  (ormap
   (lambda (z) (equal? x z))
   set1))



;; subset? : SetOf<X> SetOf<X> -> Boolean
;; strategy: HO Function Combination
(define (subset? set1 set2)
  (andmap
   (lambda (x) (my-member? x set2))
   set1))



;; set-equal? : SetOf<X> SetOf<X> -> Boolean
(define (set-equal? set1 set2)
  (and
   (subset? set1 set2)
   (subset? set2 set1)))



;; Test cases

(define tests
  (test-suite
   "q1"
   
   (limited-test-case
    "Test #1"
    ;lit 
    (check-true
     (literal?
      (lit 5.0))
     "lit function should return a literal"))
   
   
   (limited-test-case
    "Test #2"
    ;literal-value 
    (check-equal?
     (literal-value
      (lit 5.2))
     5.2
     "literal-value function should return real value of the given literal"))
   
   
   (limited-test-case
    "Test #3"
    ;var  
    (check-equal?
     (variable-name
      (var  "x1r3"))
     "x1r3"
     "variable-name function should return string value of the given variable"))
   
   
   (limited-test-case
    "Test #4"
    ;variable?  
    (check-true (variable?
                 (var  "x1r3"))
                "var function should return a variable"))
   
   
   (limited-test-case
    "Test #5"
    ;operation?  
    (check-true (operation?
                 (op  "+"))
                "op function should return a operation"))
   
   
   
   (limited-test-case
    "Test #6"
    ;call and block  
    (check-true (block?
                 (block-rhs BLOCK-1))
                "It should return a block"))
   
   (limited-test-case
    "Test #7"
    ;call and block  
    (check-true (call?
                 (block-rhs
                  (block-rhs BLOCK-1)))
                "It should return a call"))
   
   (limited-test-case
    "Test #8"
    ;call and block  
    (check-equal? (operation-name
                   (block-body
                    (block-rhs BLOCK-1)))
                  "+"
                  "It should return a OperationName"))
   
   (limited-test-case
    "Test #9"
    ;call and block  
    (check-true (set-equal?
                 (map variable-name
                      (call-operands
                       (block-body BLOCK-1)))
                 (list  "x7" "x6"))
                "It should return a operand expression of the call."))
   
   
   (limited-test-case
    "Test #10"
    ;call and block  
    (check-equal? (variable-name
                   (block-var
                    (block-rhs BLOCK-1)))
                  "z"
                  "The variable returned should be z"))
   
   (limited-test-case
    "Test #11"
    ;call and block  
    (check-true (operation?
                 (block-body
                  (block-rhs BLOCK-1)))
                "It should return true"))
   
   (limited-test-case
    "Test #12"
    ;call and block  
    (check-equal? (operation-name
                   (call-operator
                    (block-rhs (block-rhs BLOCK-1))))
                  "*"
                  "The Operation-name should be returned"))
   
   (limited-test-case
    "Test #13"
    ;call and block  
    (check-true
     (call? (call-operator
             (call
              (call (var "k")
                    (list (var "x6") (var "x7") (op "*")))
              (list (var "x6") (var "x7")))))
     "The inner call should be returned"))   
   
   
   
   (limited-test-case
    "Test #14"
    ;call and block  
    (check-equal?
     (variable-name (first
                     (call-operands
                      (call (var "k")
                            (list (var "x6"))))))
     "x6"
     "It should return x6."))
   
   (limited-test-case
    "Test #15"
    ;call and block  
    (check-true
     (call?
      (call (var "k")
            (list (var "x6") (lit 7) (op "*"))))
     "This should return true."))
   
   ))

(run-tests tests 'verbose)
