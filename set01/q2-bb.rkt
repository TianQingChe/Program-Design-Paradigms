#lang racket

(require rackunit)
(require rackunit/text-ui)
(require "q2.rkt")

(define tests
  (test-suite
   "q2"

   (test-case
    "Test #1"
    (check-pred procedure? furlongs-to-barleycorns
                "expected a procedure"))
   ))

(run-tests tests 'verbose)
