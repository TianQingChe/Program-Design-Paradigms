;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q3) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; q3.rkt: Converts a temperature in Kelvin to the temperature in Fahrenheit.

(require rackunit)
(require "extras.rkt")
(check-location "01" "q3.rkt")

(provide kelvin-to-fahrenheit)

;; A KelvinTemp is represented as a Real.
;; A FarenTemp is represented as a Real.

;; kelvin-to-fahrenheit: KelvinTemp -> FarenTemp
;; GIVEN: a temperature in Kelvin.
;; RETURNS: the equivalent temperature in Fahrenheit.
;; EXAMPLES:
;; (kelvin-to-fahrenheit 0) = -273.15
;; (kelvin-to-fahrenheit 273.15) = 0
;; DESIGN STRATEGY: Transcribe Formula

(define (kelvin-to-fahrenheit kev-temp)
  (+ -273.15 kev-temp)
  )

;;TESTS
(begin-for-test
  (check-equal? (kelvin-to-fahrenheit 0) -273.15
     "0 Kelvin should be -273.15 Fahrenheit")
  (check-equal? (kelvin-to-fahrenheit 273.15) 0
     "273.15 Kelvin should be 0 Fahrenheit")
  )