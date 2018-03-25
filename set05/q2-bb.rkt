#lang racket

(require racket/sandbox)
(require rackunit)
(require rackunit/text-ui)
(require "q2.rkt")

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




(define BLOCK-2
  (block (var "x")
         (var "y")
         (call (block (var "z")
                      (var "p")
                      (op "+"))
               (list (block (var "x")
                            (lit 5)
                            (var "m"))
                     (block (var "k")
                            (var "l")
                            (var "n"))
                     (var "j")))))



(define BLOCK-3
  (block (var "x")
         (lit 5)
         (call (block (var "z")
                      (lit 9)
                      (op "+"))
               (list (block (var "x")
                            (lit 5)
                            (op "+"))
                     (lit 7)))))


(define BLOCK-4
  (block (var "x")
         (var "x")
         (call (block (var "z")
                      (var "z")
                      (op "+"))
               (list (block (var "x")
                            (call (op "/")
                                  (list (var "x") (lit 5) (var "z")))
                            (var "m"))
                     (var "j")))))

(define BLOCK-5
  (block (var "x")
         (lit 5)
         (call (block (var "z")
                      (lit 9)
                      (op "+"))
               (list (block (var "x")
                            (lit 5)
                            (lit 9))
                     (lit 7)))))

(define CALL-1
  (call (block (var "d")
               (lit 18)
               (block (var "c")
                      (lit 19)
                      (op "/")))
        (list (lit 15) (lit 3))))



(define CALL-2
  (call (block (var "d")
               (lit 18)
               (block (var "c")
                      (lit 19)
                      (op "/")))
        (list (lit 15) (lit 3) (op "*"))))



(define CALL-3
  (call (block (var "a")
               (var "x7")
               (block (var "b")
                      (op "*")
                      (block (var "c")
                             (lit 19)
                             (op "+"))))
        (list CALL-1
              (call (block (var "z")
                           (lit 9)
                           (op "*"))
                    (list (block (var "x")
                                 (lit 5)
                                 (lit 20))
                          (lit 7))))))

;;; canonical : StringList -> StringList
;;; GIVEN: a list of strings
;;; RETURNS: a list of those strings in some canonical order

(define (canonical ss)
  (sort ss string<?))

;;; make-set : StringList -> StringList
;;; GIVEN: a list of strings
;;; RETURNS: a version of that list from which duplicates have been removed
;;; EXAMPLE:
;;;     (make-set (list "a" "b" "c" "c" "a" "c"))
;;;  => (list "a" "b" "c") or some permutation thereof

(define (make-set ss)
  (cond ((empty? ss)
         ss)
        ((member (first ss)
                 (rest ss))
         (make-set (rest ss)))
        (else
         (cons (first ss)
               (make-set (rest ss))))))




;; Test cases

(define tests
  (test-suite
   "q2"
   
   (limited-test-case
    "Test #1"
    ;variables-defined-by with duplicates as input
    (check-equal?
     (canonical (variables-defined-by BLOCK-2))
     (canonical (list "x" "z" "k"))
     "variables-defined-by should return these elements without duplicates"))
   
   (limited-test-case
    "Test #2"
    ;variables-defined-by without duplicates as input
    (check-equal?
     (canonical (variables-defined-by BLOCK-1))
     (canonical (list "x5" "z"))
     "variables-defined-by should return these elements"))
   
   (limited-test-case
    "Test #3"
    ;variables-used-by without duplicates as input
    (check-equal?
     (canonical (make-set (variables-used-by BLOCK-2)))
     (canonical (list "y" "p" "m" "l" "n" "j"))
     "variables-used-by should return these elements"))
   
   (limited-test-case
    "Test #4"
    ;variables-used-by with literals in used-by portion of block as input
    (check-true
     (empty? (variables-used-by BLOCK-3))
     "variables-used-by should return empty list"))
   
   (limited-test-case
    "Test #5"
    ;variables-used-by without any duplicates as input
    (check-equal?
     (canonical (make-set (variables-used-by BLOCK-1)))
     (canonical (list "x" "y" "x6" "x7"))
     "variables-used-by should return these elements"))
   
   (limited-test-case
    "Test #6"
    ;variables-used-by with some duplicates as input
    (check-equal?
     (canonical (make-set (variables-used-by BLOCK-4)))
     (canonical (list "x" "z" "m" "j"))
     "variables-used-by should return these elements"))
   
   (limited-test-case
    "Test #7"
    ;constant-expression?
    (check-true
     (constant-expression?
      CALL-1)
     "It should return true"))
   
   (limited-test-case
    "Test #8"
    ;constant-expression? 
    (check-false
     (constant-expression?
      CALL-2)
     "It should return false"))
   
   (limited-test-case
    "Test #9"
    ;constant-expression? 
    (check-true
     (constant-expression?
      CALL-3)
     "CALL-3 is a constant expression"))
   
   (limited-test-case
    "Test #10"
    ;constant-expression-value 
    (check-equal?
     (constant-expression-value
      CALL-1)
     5
     "It should return a 5"))
   
   (limited-test-case
    "Test #11"
    ;constant-expression-value 
    (check-equal?
     (constant-expression-value
      CALL-3)
     145
     "It should return a 145"))
   
   (limited-test-case
    "Test #12"
    ;constant-expression? with Block as input
    (check-true
     (constant-expression?
      BLOCK-5)
     "It should return true"))
   
   (limited-test-case
    "Test #13"
    ;constant-expression? with non-constant expression as input
    (check-false
     (constant-expression?
      BLOCK-3)
     "BLOCK-3 is not a constant expression"))
   
   (limited-test-case
    "Test #14"
    ;constant-expression-value with Block as input
    (check-equal?
     (constant-expression-value
      BLOCK-5)
     16
     "It should return a 16"))
   
   (limited-test-case
    "Test #15"
    ;variables-defined-by with duplicates in CALL as input
    (check-equal?
     (canonical (variables-defined-by CALL-3))
     (canonical (list "b" "a" "c" "x" "d" "z"))
     "variables-defined-by should return these elements without duplicates"))
   
   (limited-test-case
    "Test #16"
    ;variables-used-by without duplicates in CALL as input
    (check-equal?
     (canonical (variables-used-by CALL-3))
     (canonical (list "x7"))
     "variables-used-by should return x7 in list"))
   ))

(run-tests tests 'verbose)
