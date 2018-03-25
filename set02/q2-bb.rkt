#lang racket

(require rackunit)
(require rackunit/text-ui)
(require "q2.rkt")

(define tests
  (test-suite
   "q2"  
   
   (test-case
    "Test #1"
    (check-equal? (is-red? (initial-state 5)) true
                  "is-red? returns true if initial color is red"))
   
   (test-case
    "Test #2"
    (check-equal? (is-red?
                   (next-state
                    (next-state
                     (next-state
                      (next-state
                       (next-state (initial-state 5))))))) false
                                                           "is-red? returns false at sixth second from the start"))
   
   (test-case
    "Test #3"
    (check-equal? (is-green? (initial-state 5)) false
                  "is-green? returns false when light is at initial state"))
   
   (test-case
    "Test #4"
    (check-equal?
     (is-green? (next-state
                 (next-state
                  (next-state
                   (next-state
                    (next-state (initial-state 5)))))))
     true
     "returns true as traffic light is green after 5 sec"))
   
   (test-case
    "Test #5"
    (check-equal?
     (is-green?
      (next-state
       (next-state
        (next-state
         (next-state
          (next-state
           (next-state
            (next-state (initial-state 5)))))))))
     false
     "returns false since traffic light is blank at eight sec"))
   
   (test-case
    "Test #6"
    (check-equal?
     (is-green?
      (next-state
       (next-state
        (next-state
         (next-state
          (next-state
           (next-state
            (next-state
             (next-state (initial-state 5))))))))))
     true
     "returns true since traffic light is green at ninth sec"))
   
   (test-case
    "Test #7"
    (check-equal? (is-green?
                   (next-state
                    (next-state
                     (next-state
                      (next-state
                       (next-state
                        (next-state
                         (next-state
                          (next-state
                           (next-state (initial-state 5)))))))))))
                  false
                  "returns false since traffic light is blank at tenth sec"))
   
   (test-case
    "Test #8"
    (check-equal?
     (is-red?
      (next-state
       (next-state
        (next-state
         (next-state
          (next-state
           (next-state
            (next-state
             (next-state
              (next-state
               (next-state (initial-state 5))))))))))))
     true
     "returns true since traffic light is red at 11th sec"))
   
   ))
(run-tests tests 'verbose)
