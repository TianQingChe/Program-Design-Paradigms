;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q5) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; q5.rkt: Computes the number of 365-day years a miscroprocessor would take to test Java
;; double precision addition operation giving its speed.

(require rackunit)
(require "extras.rkt")
(check-location "01" "q5.rkt")

(provide years-to-test)

;; MP-Flopspeed is represented as a Number.
;; INTERP: m represents the speed of a microprocessor in FLOPS.

;; flopy: Number -> Number
;; GIVEN: the speed of a microprocessor in FLOPS
;; RETURNS: the number of 365-day years a miscroprocessor would take to test Java double
;; precision addition operation
;; EXAMPLES:
;; (years-to-test (* 2 (exp 10 9))) = 5395141535403007094485.264577495056625063419583967529173008
;; (years-to-test (* 100 (exp 10 9))) = 107902830708060141889.70529154990113250126839167935058346017
;; DESIGN STRATEGY: Multiplying the speed with the number of seconds a 365-day year has. 

(define (years-to-test m)
  (/ (expt 2 128) (* m 60 60 24 365))
  )

;;TESTS
(begin-for-test
  (check-equal? (years-to-test (* 2 (expt 10 9))) 5395141535403007094485.264577495056625063419583967529173008
     (string-append "It will take the microprocessor"
                    (number->string 5395141535403007094485.264577495056625063419583967529173008)   
      "365-day years to complete this calculation"))
  (check-equal? (years-to-test (* 100 (expt 10 9))) 107902830708060141889.70529154990113250126839167935058346017
     (string-append "It will take the microprocessor"
                    (number->string 107902830708060141889.70529154990113250126839167935058346017)   
      "365-day years to complete this calculation"))
  )