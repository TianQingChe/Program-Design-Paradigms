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

;; Defining some constants



(define tests
  (test-suite
   "q1"
   
   (limited-test-case
    "Test #1"
    ;inner product
    (check-equal?
     (inner-product (list 1.5 7.0) (list 7.5 2)) 25.25
     "inner product on same length list should give sum of products"))
   
   (limited-test-case
    "Test #2"
    ;inner product
    (check-equal?
     (inner-product (list 1 2 3 4 5) (list 1 2 3 4 0)) 30 
     "inner product on same length list should give sum of products"))
   
   (limited-test-case
    "Test #3"
    ;inner product
    (check-equal?
     (inner-product (list) (list)) 0 
     "inner product on same length list should give sum of products"))
   
   (limited-test-case
    "Test #4"
    ;permutation-of?
    (check-true (permutation-of?  (list) (list))
                  "permutation-of? empty list should return true"))
   
   
   (limited-test-case
    "Test #5"
    ;permutation-of?
    (check-false (permutation-of?  (list 1 2 4) (list))
                  "permutation-of? fn on unequal lists should return false"))
   
   
   (limited-test-case
    "Test #6"
    ;permutation-of?
    (check-true
     (permutation-of?
      (list 7 8 9 4 5 6 1 3 2) (list 1 2 3 4 5 6 7 8 9))
     "permutation-of? fn should return true"))
   
   
   ;; INVALID TEST - contract says no duplicates
   #;(limited-test-case
    "Test #7"
    ;permutation-of?
    (check-false
     (permutation-of?  (list 7 8 9 4 5 6 1 3 2 4) (list 1 2 3 4 5 6 7 8 9 9))
     "permutation-of? on list with two different duplicates
     should return false"))
   
   (limited-test-case
    "Test #8"
    ;permutation-of?
    (check-true
     (permutation-of?  (list 7 8 9 4 5 6 1 3 2) (list 1 2 3 4 5 6 7 8 9))
     "permutation-of? fn should return true"))
   
   
   (limited-test-case
    "Test #9"
    ;permutation-of?
    (check-false (permutation-of?  (list 1 2 4) (list 7 8 9))
                  "permutation-of? fn on unequal lists should return false"))
   
   (limited-test-case
    "Test #10"
    ;shortlex-less-than?
    (check-false (shortlex-less-than?  (list) (list))
                  "shortlex-less-than? fn on empty list should return false"))
   
   
   (limited-test-case
    "Test #11"
    ;shortlex-less-than?
    (check-false (shortlex-less-than?  (list 1 1 1) (list 1 1 1))
                  "shortlex-less-than? fn on equal list should return false"))
   
   
   (limited-test-case
    "Test #12"
    ;shortlex-less-than?
    (check-true (shortlex-less-than?  (list 1 1 1 1 1) (list 1 1 1 1 2))
                  "shortlex-less-than? fn should return true"))
   
   
   (limited-test-case
    "Test #13"
    ;shortlex-less-than?
    (check-false
     (shortlex-less-than?  (list 1 1 1 1 1) (list 1 1 1 0 2))
     "shortlex-less-than? fn should return false"))
   
   
   (limited-test-case
    "Test #14"
    ;shortlex-less-than?
    (check-true (shortlex-less-than?  (list) (list 8 9 9))  
                  "shortlex-less-than? fn should return true"))
   
   
   (limited-test-case
    "Test #15"
    ;shortlex-less-than?
    (check-false (shortlex-less-than?   (list 8 9 9) (list)) 
                  "shortlex-less-than? fn should return false"))
   
   
   (limited-test-case
    "Test #16"
    ;shortlex-less-than?
    (check-false (shortlex-less-than?  (list 1 1 3 0 2) (list 1 1 1 0 2))
                  "shortlex-less-than? fn should return false"))
   
   
   
   
   (limited-test-case
    "Test #17"
    ;permutations 
    (check-equal?
     (permutations (list 3 4 2 1)) (list
                                    (list 1 2 3 4)
                                    (list 1 2 4 3)
                                    (list 1 3 2 4)
                                    (list 1 3 4 2)
                                    (list 1 4 2 3)
                                    (list 1 4 3 2)
                                    (list 2 1 3 4)
                                    (list 2 1 4 3)
                                    (list 2 3 1 4)
                                    (list 2 3 4 1)
                                    (list 2 4 1 3)
                                    (list 2 4 3 1)
                                    (list 3 1 2 4)
                                    (list 3 1 4 2)
                                    (list 3 2 1 4)
                                    (list 3 2 4 1)
                                    (list 3 4 1 2)
                                    (list 3 4 2 1)
                                    (list 4 1 2 3)
                                    (list 4 1 3 2)
                                    (list 4 2 1 3)
                                    (list 4 2 3 1)
                                    (list 4 3 1 2)
                                    (list 4 3 2 1)) 
     "permutations  fn should return all possible permutations
      in the shortlex order"))
   
   
   
   (limited-test-case
    "Test #18"
    ;permutations 
    (check-equal?
     (permutations (list)) (list (list)) 
     "permutations  fn should return list of empty list as output"))
   
   
   
   (limited-test-case
    "Test #19"
    ;permutations 
    (check-equal?
     (permutations (list 1)) (list (list 1)) 
     "permutations  fn should return list of empty list as output"))

   )
  )

(run-tests tests 'verbose)
