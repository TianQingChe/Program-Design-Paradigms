#lang racket

(require rackunit)
(require rackunit/text-ui)
(require "q1.rkt")

(define tests
  (test-suite
   "q1"

   (test-case
    "Test #1"
    (check-pred procedure? pyramid-volume
                "expected a procedure"))
   ))

(run-tests tests 'verbose)
