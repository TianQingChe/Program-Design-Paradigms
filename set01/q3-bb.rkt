#lang racket

(require rackunit)
(require rackunit/text-ui)
(require "q3.rkt")

(define tests
  (test-suite
   "q3"

   (test-case
    "Test #1"
    (check-pred procedure? kelvin-to-fahrenheit
                "expected a procedure"))
   ))

(run-tests tests 'verbose)
