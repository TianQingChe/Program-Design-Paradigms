#lang racket
(require racket/sandbox)
(require rackunit)
(require rackunit/text-ui)
(require "q2.rkt")



;; Test case utilities

(define TIME-LIMIT-S 20)
(define MEMORY-LIMIT-MB 128)

(define-syntax limited-test-case
  (syntax-rules ()
    ((_ name body ...)
     (test-case name
                (with-limits TIME-LIMIT-S
                             MEMORY-LIMIT-MB
                             body ...)))))

;; Abbreviation
(define ++ string-append)




(define tests
  (test-suite
   "q1"

   
   (limited-test-case
    "Test #1"
    ;well-typed? 
    (check-true
     (well-typed? (lit 25)) 
     "well-typed? fn should return true"))


  (limited-test-case
    "Test #2"
    ;well-typed? 
    (check-false
     (well-typed? (var "b")) 
     "well-typed? fn should return false"))


  (limited-test-case
    "Test #3"
    ;well-typed? 
    (check-false
     (well-typed? (call (op "/" ) (list))) 
     "well-typed? fn should return false"))


  (limited-test-case
   "Test #4"
   ;well-typed? 
   (check-true
    (well-typed?
     (call (op "/" )
           (list (lit 7) (lit 8) (lit 9) (lit 5)))) 
    "well-typed? fn should return true"))


  (limited-test-case
    "Test #5"
    ;well-typed? 
    (check-true
     (well-typed? (call (op "*" ) (list))) 
     "well-typed? fn should return true"))


  (limited-test-case
   "Test #6"
   ;well-typed? 
   (check-false
    (well-typed?
     (call (op "/" )
           (list (lit 7) (lit 8) (lit 9) (var "a") (op "-")))) 
    "well-typed? fn should return false"))



  (limited-test-case
   "Test #7"
   ;well-typed? 
   (check-false
    (well-typed?
     (call (var "a")
           (list (lit 7)))) 
    "well-typed? fn should return false"))



  (limited-test-case
   "Test #8"
   ;well-typed? 
   (check-false
    (well-typed?
     (block (var "f")
            (call (var "f")
                  (list (lit 7)))
            (lit 5))) 
    "well-typed? fn should return false"))
  
  (limited-test-case
   "Test #9"
   ;well-typed? 
   (check-true
    (well-typed?
     (block (var "f")
            (call (op "*")
                  (list (lit 7)))
            (call (op "*")
                  (list (var "f"))))) 
    "well-typed? fn should return false"))
  

  (limited-test-case
   "Test #10"
   ;well-typed? 
   (check-true
    (well-typed?
     (block (var "f")
       (call (op "*" ) (list))
       (block (var "f")
            (call (op "/")
                  (list (var "f")))
            (call (op "*")
                  (list (var "f")))))) 
    "well-typed? fn should return true"))

  (limited-test-case
   "Test #11"
   ;well-typed? 
   (check-true
    (well-typed?
     (block (var "f")
      (op "*")
       (block (var "x")
            (call (var "f")
                  (list (lit 9)))
            (call (op "*")
                  (list (var "x")))))) 
    "well-typed? fn should return true"))

  (limited-test-case
   "Test #12"
   ;well-typed? 
   (check-true
    (well-typed?
     (block (var "r")
       (block (var "a")
              (op "+")
              (block (var "b")
                     (call (var "a")
                           (list (call (var "a") (list))
                                 (call (var "a") (list (lit 7)))))
                     (block (var "c")
                            (block
                             (var "c")
                             (call (var "a") (list (var "b") (lit 5)))
                             (var "a"))
                            (var "c"))))
       (block (var "f")
              (var "r")
              (block (var "x")
                     (call (var "f")
                           (list (lit 9)))
                     (call (var "r")
                           (list (var "x"))))))) 
    "well-typed? fn should return true"))



  (limited-test-case
   "Test #13"
   ;well-typed? 
   (check-true
    (well-typed?
     (call
      (block (var "a")
             (call (op "*") (list (lit 5) (lit 9)))
             (block (var "b")
                    (block (var "c")
                           (lit 5)
                           (op "-"))
                    (block (var "d")
                           (call (var "b")
                                 (list (lit 5) (var "a")))
                           (var "b"))))
      (list (lit 7) (lit 6)))) 
    "well-typed? fn should return true"))



  (limited-test-case
   "Test #14"
   ;well-typed? 
   (check-false
    (well-typed?
     (call
      (block (var "a")
             (call (op "*") (list (lit 5) (lit 9)))
             (block (var "b")
                    (block (var "c")
                           (lit 5)
                           (op "-"))
                    (block (var "d")
                           (call (var "b")
                                 (list (lit 5) (var "a")))
                           (var "b"))))
      (list))) 
    "well-typed? fn should return false"))



(limited-test-case
   "Test #15"
   ;well-typed? 
   (check-false
    (well-typed?
     (block (var "r")
       (block (var "a")
              (op "+")
              (block (var "b")
                     (call (var "a")
                           (list (call (var "a") (list))
                                 (call (var "a") (list (lit 7)))))
                     (block (var "c")
                            (block
                             (var "c")
                             (var "a")
                             (call (var "c") (list (var "b") (lit 5))))
                            (var "c"))))
       (block (var "f")
              (var "r")
              (block (var "x")
                     (call (var "f")
                           (list (lit 9)))
                     (call (var "r")
                           (list (var "x"))))))) 
    "well-typed? fn should return false"))

))

(run-tests tests 'verbose)
