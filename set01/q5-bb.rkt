#lang racket

(require rackunit)
(require rackunit/text-ui)
(require "q5.rkt")

(define tests
  (test-suite
   "q5"

   (test-case
    "Test #1"
    (check-pred procedure? years-to-test
                "expected a procedure"))
   ))

(run-tests tests 'verbose)
