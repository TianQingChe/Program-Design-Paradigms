;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q2-bb) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;;#lang racket

(require rackunit)
(require rackunit/text-ui)
(require "q2.rkt")

;; Defining some constants
(define SPACE-BAR " ")
(define BUTTON-UP "button-up")
(define BUTTON-DOWN "button-down")
(define DRAG "drag")

(define UP "up")
(define SPEED 0.5)
;;Initial world with 0.5 secs per tick
(define INITIAL-WORLD (initial-world SPEED))
;; World in a rally state
(define WORLD-RALLY-STATE (world-after-key-event
                           INITIAL-WORLD SPACE-BAR))



;; World with a racket with 3 speed in up direction.
(define WORLD-RACKET-WITH-3SPEED
  (world-after-key-event
   (world-after-key-event
    (world-after-key-event WORLD-RALLY-STATE UP) UP) UP))





;; Racket in rally state 
(define RACKET-IN-RALLYSTATE (world-racket WORLD-RALLY-STATE))


;; Racket in selected state 
(define SELECTED-RACKET-RALLY-STATE (racket-after-mouse-event RACKET-IN-RALLYSTATE 335 388 BUTTON-DOWN))


(define tests
  (test-suite
   "q1"
   (test-case
    "Test #1"
    ;button down event on racket when world is in ready to serve state
    (check-equal? (racket-selected?
                   (world-racket
                    (world-after-mouse-event INITIAL-WORLD 330 384 BUTTON-DOWN) ))
                  #f
                  "Racket should not get selected when world is in ready to serve state"))
   
   
   (test-case
    "Test #2"
    ;button down event on racket when world is in rally state
    (check-equal? (racket-selected?
                   (world-racket
                    (world-after-mouse-event WORLD-RALLY-STATE 330 384 BUTTON-DOWN) ))
                  #t
                  "Racket should get selected when world is in rally state"))
   
   (test-case
    "Test #3"
    ;button down event on racket's 25 radius circle when world is in rally state
    (check-equal? (racket-selected? (racket-after-mouse-event RACKET-IN-RALLYSTATE 335 388 BUTTON-DOWN))
                  #t
                  "Racket should get selected when world is in rally state and button down is in the 25 radius circle"))
   
   
   (test-case
    "Test #4"
    ;button-down event outside 25 radius circle of racket and world is in rally state 
    (check-equal? (racket-selected? (racket-after-mouse-event RACKET-IN-RALLYSTATE 364 408 BUTTON-DOWN))
                  #f
                  "Racket should not get selected if button-down event happened outside 25 radius circle"))
   
   
   (test-case
    "Test #5"
    ;Racket should folow smooth dragging; check for x coordinate
    (check-equal? (racket-x (racket-after-mouse-event SELECTED-RACKET-RALLY-STATE 336 10 DRAG))
                  331
                  "Drag even should happen smoothly"))
   
   
   (test-case
    "Test #6"
    ;Racket should folow smooth dragging; check for y coordinate
    (check-equal? (racket-y (racket-after-mouse-event SELECTED-RACKET-RALLY-STATE 336 10 DRAG))
                  6
                  "Drag even should happen smoothly"))
   
   
   
   (test-case
    "Test #7"
    ;Racket should not move when it is selected
    (check-equal?
     (racket-y
      (world-racket
       (world-after-tick
        (world-after-mouse-event WORLD-RACKET-WITH-3SPEED 335 388 BUTTON-DOWN))))
     384
     "Racket should not move when it is selected"))
   
   
   
   (test-case
    "Test #8"
    ;selected racket on release will move with the old velocity
    (check-equal?
     (racket-y
      (world-racket
       (world-after-tick
        (world-after-mouse-event 
         ( world-after-mouse-event
           (world-after-tick
            (world-after-mouse-event WORLD-RACKET-WITH-3SPEED 330 384 BUTTON-DOWN))
           200 200
           DRAG) 200 200 BUTTON-UP))))
     197
     "The racket should start moving once it is released with its old velocity"))
   
   (test-case
    "Test #9"
    ;selected racket on release will have the old velocity 
    (check-equal? (racket-vy
                   (world-racket
                    (world-after-tick
                     (world-after-mouse-event 
                      ( world-after-mouse-event
                        (world-after-tick
                         (world-after-mouse-event WORLD-RACKET-WITH-3SPEED 330 384 BUTTON-DOWN))
                        200 200
                        DRAG) 200 200 BUTTON-UP))))
                  -3
                  "The racket velocity should be same as before selection"))
   
   
   ))


(run-tests tests 'verbose)
