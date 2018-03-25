#lang racket
(require racket/sandbox)
(require rackunit)
(require rackunit/text-ui)
(require "q1.rkt")



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

;; Defining some constants
(define BLOCK-1
  (block (var "x5")
         (block (var "z")
                (call (op "*")
                      (list (var "x") (var "y")))
                (var "z"))
         (call (op "*")
               (list (var "x6") (var "x7")))))




(define BLOCK-2
  (block (var "p")
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
                     (var "k")))))


(define BLOCK-3
  (block (var "x")
         (var "j")
         (call (block (var "z")
                      (var "z")
                      (op "+"))
               (list (block (var "x")
                            (var "x")
                            (var "n"))
                     (block (var "m")
                            (var "z")
                            (block (var "x")
                                   (lit 5)
                                   (var "m")))
                     (block (var "z")
                            (op "+")
                            (var "z"))
                     (block (var "z")
                            (var "n")
                            (op "+"))))))


(define BLOCK-4
  (block (var "x")
         (block (var "x")
                (var "x")
                (var "x"))
         (block (var "y")
                (var "x")
                (block (var "z")
                       (var "x")
                       (block (var "k")
                              (var "z")
                              (block (var "a")
                                     (var "y")
                                     (call (var "y")
                                           (list (block (var "b")
                                                        (var "a")
                                                        (var "z"))
                                                 (block (var "x")
                                                        (var "x")
                                                        (var "z"))))))))))

(define CALL-1
  (call (block (var "d")
               (lit 18)
               (block (var "c")
                      (var "d")
                      (op "/")))
        (list (lit 15) (lit 3) (var "c"))))




(define CALL-2
  (call (block (var "a")
               (var "x")
               (block (var "b")
                      (op "*")
                      (block (var "c")
                             (var "a")
                             (op "+"))))
        (list CALL-1
              (call (block (var "z")
                           (lit 9)
                           (op "*"))
                    (list (block (var "x")
                                 (var "z")
                                 (lit 20))
                          )))))


(define CALL-3
  (call (block (var "x")
               (lit 9)
               (block (var "z")
                      (op "*")
                      (block (var "c")
                             (var "x")
                              CALL-2)))
        (list (lit 8)
              (call (block (var "z")
                           (lit 9)
                           (var "z"))
                    (list (block (var "x")
                                 (lit 6)
                                 (lit 20))
                          )))))


;;; canonical : StringList -> StringList
;;; GIVEN: a list of strings
;;; RETURNS: a list of those strings in some canonical order

(define (canonical ss)
  (sort ss string<?))

(define tests
  (test-suite
   "q1"
   
   (limited-test-case
    "Test #1"
    ;undefined-variables 
    (check-equal?
     (canonical (undefined-variables
                 (call (var "f")
                       (list  (var "x")
                              (var "x")
                              (var "x")
                              (var "y")
                              (lit 7)
                              (var "y")
                              (var "z")))))
     (canonical (list "f" "x" "y" "z")) 
     "undefined-variables fn should return list of undefined
      variables without duplicate"))


   (limited-test-case
    "Test #2"
    ;undefined-variables 
    (check-equal?
     (canonical (undefined-variables
                 BLOCK-1))
     (canonical (list "x" "y" "x6" "x7")) 
     "undefined-variables fn should return list of undefined
      variables without duplicate"))



   (limited-test-case
    "Test #3"
    ;undefined-variables 
    (check-equal?
     (canonical (undefined-variables
                 (call (var "f")
                       (list (block (var "x")
                                    (var "x")
                                    (var "x"))
                             (block (var "y")
                                    (lit 7)
                                    (var "y"))
                             (var "z")))))
     (canonical (list "x" "f" "z")) 
     "undefined-variables fn should return list of undefined
      variables without duplicate"))



   (limited-test-case
    "Test #4"
    ;undefined-variables 
    (check-equal?
     (canonical (undefined-variables
                 (call (var "f")
                       (list (block (var "x")
                                    (lit 5)
                                    (var "y"))
                             (block (var "y")
                                    (lit 7)
                                    (var "x"))
                             (var "z")))))
     (canonical (list "x" "f" "z" "y")) 
     "undefined-variables fn should return list of undefined
      variables without duplicate"))

   (limited-test-case
    "Test #5"
    ;undefined-variables 
    (check-equal?
     (canonical (undefined-variables
                 (call (block (var "a")
                              (var "b")
                              (var "c"))
                       (list (block (var "c")
                                    (lit 17)
                                    (var "c"))
                             (block (var "b")
                                    (lit 18)
                                    (var "b"))))))
     (canonical (list "b" "c")) 
     "undefined-variables fn should return list of undefined
      variables without duplicate"))

   (limited-test-case
    "Test #6"
    ;undefined-variables 
    (check-true
     (empty? (undefined-variables
                 (call (block (var "a")
                              (lit 0)
                              (var "a"))
                       (list (block (var "c")
                                    (lit 17)
                                    (var "c"))
                             (block (var "b")
                                    (lit 18)
                                    (var "b"))))))
      
     "undefined-variables fn should return an empty list"))

   (limited-test-case
    "Test #7"
    ;undefined-variables 
    (check-equal?
     (canonical (undefined-variables
                 BLOCK-2))
     (canonical '("k" "l" "m" "n" "y")) 
     "undefined-variables fn should return list of undefined
      variables without duplicate"))

   (limited-test-case
    "Test #8"
    ;undefined-variables 
    (check-equal?
     (canonical (undefined-variables
     (lit 7)))
     '() 
     "undefined-variables fn should return empty list"))



   (limited-test-case
    "Test #9"
    ;undefined-variables 
    (check-equal?
     (canonical (undefined-variables
     (var "y")))
     '("y") 
     "undefined-variables fn should return a list of undefined variables"))

   (limited-test-case
    "Test #10"
    ;undefined-variables 
    (check-equal?
     (canonical (undefined-variables
     (op "+")))
     '() 
     "undefined-variables fn should return empty list"))


   (limited-test-case
    "Test #11"
    ;undefined-variables 
    (check-equal?
     (canonical (undefined-variables BLOCK-3))
     (canonical (list "j" "z" "n"))
     "undefined-variables fn should return a list of undefined variables"))

   (limited-test-case
    "Test #12"
    ;undefined-variables 
    (check-equal?
     (canonical (undefined-variables CALL-1))
     (canonical (list "c"))
     "undefined-variables fn should return a list of undefined variables"))

   (limited-test-case
    "Test #13"
    ;undefined-variables 
    (check-equal?
     (canonical (undefined-variables CALL-2))
     (canonical (list "x" "z" "c"))
     "undefined-variables fn should return a list of undefined variables"))

   (limited-test-case
    "Test #14"
    ;undefined-variables 
    (check-true
     (empty? (undefined-variables CALL-3))
     "undefined-variables fn should return an empty list"))


   (limited-test-case
    "Test #15"
    ;undefined-variables 
    (check-equal?
     (canonical (undefined-variables BLOCK-4))
     (canonical (list "x"))
     "undefined-variables fn should return a list of undefined variables"))

   )
  )

(run-tests tests 'verbose)


