;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; q1.rkt: Computes the volume of a pyramid using its height and side length of square bottom

(require rackunit)
(require "extras.rkt")
(check-location "01" "q1.rkt")

(provide pyramid-volume)

;; A side length is represented as Number
;; Interp: x represents the side length of bottom square of the pyramid in units of meters

;; A height is represented as a Number
;; Interp: h represents the height of a pyramid in units of meters

;; pyramid-volume: Number Number -> Number
;; GIVEN: side length of bottom square and height of a pyramid
;; RETURNS: volume of the pyramid
;;EXAMPLES:
;; (pyramid-volume 3 4) = 12
;; (pyramid-volume 7 6) = 98
;; DESIGN STRATEGY: Transcribe Formula

(define (pyramid-volume x h)
  (* (/ 1 3) (* x x) h)
  )

;; TESTS
(begin-for-test
  (check-equal? (pyramid-volume 3 4) 12
      "Volume of this pyramid(3 meters, 4 meters) should be 12 cubic meters")
  (check-equal? (pyramid-volume 7 6) 98
      "Volume of this pyramid(7 meters, 6 meters) should be 98 cubic meters")
  )
