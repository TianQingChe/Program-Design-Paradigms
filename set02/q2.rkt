;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(check-location "02" "q2.rkt")

(provide
 initial-state
 next-state
 is-red?
 is-green?)

;;; DATA DEFINITIONS

;;; Color
;;; a color is represented by one of the strings
;;; -- "red"
;;; -- "green"
;;; -- "blank"
;;; INTERP: self-evident
(define red-color "red")
(define green-color "green")
(define blank-color "blank")

;;; TimerState
;;; a TimerState is reprsented by a PosInt
;;; WHERE: 0<TimerState<=signal-cycle
;;; INTERP: number of seconds until the end of a complete signal cycle

;;; SignalCycle
;;; a SignalCycle is represneted by a PosInt
;;; INTERP: total number of seconds of a signal cycle

;;; ChineseTrafficSignal
;;; REPRESENTATION:
;;; a ChineseTrafficSignal is represented as a struct (make-ctsignal color time-left signal-cycle)
;;; color        : Color  represents the current color of the signal
;;; time-left    : TimerState  represents the time left until the end of a complete signal cycle,
;;; signal-cycle : SignalCycle represents the time period of a complete signal cycle;
;;;                a complete signal cycle is two times red-time-period.     

;;; IMPLEMENTATION:
(define-struct ctsignal (color time-left signal-cycle))

;;; CONSTRUCTOR TEMPLATE
;; (make-ctsignal Color TimerState SignalCycle)

;;; OBSERVER TEMPLATE
;;; ctsignal : ChineseTrafficSignal -> ??
(define (ctsignal-fn s)
  (...
   (ctsignal-color s)
   (ctsignal-time-left s)
   (ctsignal-signal-cycle s)))

;;; FUNCTIONS

;;; initial-state : PosInt -> ChineseTrafficSignal
;;; GIVEN: an integer n greater than 3
;;; RETURNS: a representation of a Chinese traffic signal
;;;     at the beginning of its red state, which will last
;;;     for n seconds
;;; EXAMPLE:
;;;     (is-red? (initial-state 4))  =>  true
(define (initial-state n)
  (make-ctsignal red-color (* 2 n) (* 2 n)))
(begin-for-test
  (check-equal?
   true (is-red? (initial-state 4))))

;;; next-state : ChineseTrafficSignal -> ChineseTrafficSignal
;;; GIVEN: a representation of a traffic signal in some state
;;; RETURNS: the state that traffic signal should have one second later;
;;; DESIGN STRATEGY: Combine simpler functions and use constructor template for ChineseTrafficSignal
(define (next-state s)
  (make-ctsignal
   (next-color (ctsignal-color s) (ctsignal-time-left s) (ctsignal-signal-cycle s))
   (next-timer (ctsignal-time-left s) (ctsignal-signal-cycle s))
   (ctsignal-signal-cycle s)))

;;; next-timer: TimerState SignalCycle-> TimerState
;;; GIVEN: a TimerState and a SignalCycle
;;; RETURNS: the TimerState at the next second
;;; EXAMPLES:
;;;    (next-timer 5 8)=4
;;;    (next-timer 1 8)=8
;;; DESIGN STRATEGY: Divide into cases
(define (next-timer t s)
  (if (= t 1)
      s
      (- t 1)))
(begin-for-test
  (check-equal?
   (next-timer 5 8) 4)
  (check-equal?
   (next-timer 1 8) 8))

;;; next-color: Color  TimerState SignalCycle-> Color
;;; GIVEN: a Color c, a TimerState t and a SignalCycle s
;;; RETURNS: the color of the ChineseTrafficSignal at the next second
;;;          if the time-left=(s/2)+1, then the color should change from
;;;          red to green at the next second;
;;;          if the time-left=4, then the color should change from green to blank
;;;          at the next second;
;;;          if the time-left=3, then the color should change from blank to green
;;;          at the next second;
;;;          if the time-left=2, then the color should change from green to blank
;;;          at the next second;
;;;          if the time-left=1, then the color should change from blank to red
;;;          at the next second;
;;; EXAMPLES:
;;;     (next-color red-color 35 60)="red"
;;;     (next-color red-color 31 60)="green"
;;;     (next-color red-color 4 60)="blank"
;;;     (next-color red-color 3 60)="green"
;;;     (next-color red-color 2 60)="blank"
;;;     (next-color red-color 1 60)="red"
;;; DESIGN STRATEGY: Divide into cases
(define (next-color c t s)
  (cond
    [(= t (+ (/ s 2) 1)) green-color]
    [(= t 4) blank-color]
    [(= t 3) green-color]
    [(= t 2) blank-color]
    [(= t 1) red-color]
    [else c]))
(begin-for-test
  (check-equal?
   (next-color red-color 35 60) "red")
  (check-equal?
   (next-color red-color 31 60) "green")
  (check-equal?
   (next-color red-color 4 60) "blank")
  (check-equal?
   (next-color red-color 3 60) "green")
  (check-equal?
   (next-color red-color 2 60) "blank")
  (check-equal?
   (next-color red-color 1 60) "red"))

;;; is-red? : ChineseTrafficSignal -> Boolean
;;; GIVEN: a representation of a traffic signal in some state
;;; RETURNS: true if and only if the signal is red
;;; EXAMPLES:
;;;     (is-red? (next-state (initial-state 4)))  =>  true
;;;     (is-red?
;;;      (next-state
;;;       (next-state
;;;        (next-state (initial-state 4)))))  =>  true
;;;     (is-red?
;;;      (next-state
;;;       (next-state
;;;        (next-state
;;;         (next-state (initial-state 4))))))  =>  false
;;;     (is-red?
;;;      (next-state
;;;       (next-state
;;;        (next-state
;;;         (next-state
;;;          (next-state (initial-state 4)))))))  =>  false
;;; DESIGN STRATEGY: Use system-defined function string=? to compare different color
(define (is-red? s)
  (string=? (ctsignal-color s) red-color))
(begin-for-test
  (check-equal?
   true (is-red? (next-state (initial-state 4))))
  (check-equal?
   true (is-red?
         (next-state
         (next-state
         (next-state (initial-state 4))))))
  (check-equal?
   false (is-red?
          (next-state
          (next-state
          (next-state
          (next-state (initial-state 4)))))))
  (check-equal?
   false (is-red?
          (next-state
          (next-state
          (next-state
          (next-state
          (next-state (initial-state 4)))))))))


;;; is-green? : ChineseTrafficSignal -> Boolean
;;; GIVEN: a representation of a traffic signal in some state
;;; RETURNS: true if and only if the signal is green
;;; EXAMPLES:
;;;     (is-green?
;;;      (next-state
;;;       (next-state
;;;        (next-state
;;;         (next-state (initial-state 4))))))  =>  true
;;;     (is-green?
;;;      (next-state
;;;       (next-state
;;;        (next-state
;;;         (next-state
;;;          (next-state (initial-state 4)))))))  =>  false
(define (is-green? s)
  (string=? (ctsignal-color s) green-color))
(begin-for-test
  (check-equal?
   true (is-green?
         (next-state
         (next-state
         (next-state
         (next-state (initial-state 4)))))))
  (check-equal?
   false (is-green?
          (next-state
          (next-state
          (next-state
          (next-state
          (next-state (initial-state 4)))))))))