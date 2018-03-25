;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q4) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; q4.rkt: Computes the number of floating point operations a microprocessor can perform
;; in one 365-day year knowing its speed.

(require rackunit)
(require "extras.rkt")
(check-location "01" "q4.rkt")

(provide flopy)

;; MP-Flopspeed is represented as a Number.
;; INTERP: m represents the speed of a microprocessor in FLOPS.

;; flopy: Number -> Number
;; GIVEN: the speed of a microprocessor in FLOPS
;; RETURNS: the number of floating point operations it can perform in one 365-day year
;; EXAMPLES:
;; (flopy (* 2 (expt 10 9))) = 63072000000000000
;; (flopy (* 100 (expt 10 9))) = 3153600000000000000 
;; DESIGN STRATEGY: Multiplying the speed with the number of seconds a 365-day year has. 

(define (flopy m)
  (* m 365 24 60 60)
  )

;;TESTS
(begin-for-test
  (check-equal? (flopy (* 2 (expt 10 9))) 63072000000000000
     "The microprocessor (speed: (* 2 (exp 10 9) FLOPS) can perform 63072000000000000 floating point operations in a 365-day year")
  (check-equal? (flopy (* 100 (expt 10 9))) 3153600000000000000 
     "The microprocessor(speed: (* 100 (exp 10 9) FLOPS) can perform 63072000000000000 floating point operations in a 365-day year")
  )