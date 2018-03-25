#lang racket

(require rackunit)
(require rackunit/text-ui)
(require "q4.rkt")

(define tests
  (test-suite
   "q4"

   (test-case
    "Test #1"
    (check-pred procedure? flopy
                "expected a procedure"))
   ))

(run-tests tests 'verbose)
