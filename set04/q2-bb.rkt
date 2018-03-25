;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q2-bb) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;;#lang racket

(require rackunit)
(require rackunit/text-ui)
(require "q2.rkt")

;; Abbreviation
(define ++ string-append)

;; Defining some constants
(define SPACE-BAR " ")
(define B-KEY "b")
(define BUTTON-UP "button-up")
(define BUTTON-DOWN "button-down")
(define DRAG "drag")

(define UP "up")
(define SPEED 0.5)


;;Initial world with 0.5 secs per tick
(define INITIAL-WORLD (initial-world SPEED))


;; Initial number of balls
(define INIT-BALL 1)


;; World in a rally state
(define WORLD-RALLY-STATE (world-after-key-event
                           INITIAL-WORLD SPACE-BAR))


;; World with a racket with 3 speed in up direction.
(define WORLD-RACKET-WITH-3SPEED
  (world-after-key-event
   (world-after-key-event
    (world-after-key-event WORLD-RALLY-STATE UP) UP) UP))


;; world-after-n-ticks : World PosInt -> World
;; Given a state of a World and a positive integer n
;; Returns World after n number of ticks.
(define (world-after-n-ticks w n)
  (if (= n 0)
      w
      (world-after-n-ticks (world-after-tick w) (- n 1))))


;; World with 2 new ball and 10 tick gap
(define WORLD-2NEW-BALLS-10-TICK
  (world-after-key-event
   (world-after-n-ticks
    (world-after-key-event WORLD-RALLY-STATE B-KEY) 10) B-KEY))


;; World with new two balls at the same position
(define NEW-BALL (second
                  (world-balls
                   (world-after-key-event
                    (world-after-key-event
                     (world-after-key-event
                      INITIAL-WORLD SPACE-BAR) B-KEY) B-KEY))))



;; world after 114 ticks with first ball near bottom wall
;; and with two new balls in the starting position
(define WORLD-AFTER-114-TICKS-2NEW-BALLS
  (world-after-key-event
   (world-after-key-event
    (world-after-n-ticks WORLD-RALLY-STATE 114) B-KEY) B-KEY))


;; Racket in selected state 
(define WORLD-SELECTED-RACKET
  (world-after-mouse-event
   WORLD-AFTER-114-TICKS-2NEW-BALLS 330 384 BUTTON-DOWN))


;; racket in new position (336, 367)
(define WORLD-DRAG-SELECTED-RACKET
  (world-after-mouse-event
   (world-after-mouse-event
    WORLD-SELECTED-RACKET 336 367 DRAG)
   336 367 BUTTON-UP))


;; WORLD-DRAG-SELECTED-RACKET after 2 ticks (116 ticks total)
;; (world has only two newly created balls)
(define WORLD-DRAG-2TICKS (world-after-n-ticks WORLD-DRAG-SELECTED-RACKET 2))


;; World where racket and 2 balls collide with tentative negative
;; velocity and with racket velocity as -3
(define WORLD-WITH-COLLISION
  (world-after-n-ticks
   (world-after-key-event
    (world-after-key-event
     (world-after-key-event
      (world-after-mouse-event
       (world-after-mouse-event
        (world-after-mouse-event
         (world-after-n-ticks WORLD-AFTER-114-TICKS-2NEW-BALLS 62)
         330 384 BUTTON-DOWN)
        330 198 DRAG)
       330 198 BUTTON-UP)
      UP)
     UP)
    UP)
   2))


(define tests
  (test-suite
   "q2"
   (test-case
    "Test #1"
    ;pressing key b in ready-to-serve state
    (check-equal?
     (length (world-balls (world-after-key-event INITIAL-WORLD B-KEY)))
     INIT-BALL
     "pressing key b in ready-to-serve state should not add new ball"))
   
   
   
   (test-case
    "Test #2"
    ;pressing key b in rally state
    (check-equal?
     (length (world-balls (world-after-key-event WORLD-RALLY-STATE B-KEY)))
     (+ INIT-BALL 1)
     "pressing key b in rally state should add new ball"))
   
   
   (test-case
    "Test #3"
    ;; world after 115 ticks(first new ball hits the bottom wall) + 1 tick
    ;; should remove the first added new ball
    (check-equal?
     (length (world-balls (world-after-n-ticks WORLD-2NEW-BALLS-10-TICK 106)))
     1
     (++ "world after 115 ticks(first new ball hits the bottom wall) + 1 tick "
         "should remove the first added new ball")))
   
   
   (test-case
    "Test #4"
    ;; world after 125 ticks(first new ball hits the bottom wall) + 1 tick
    ;; should remove the second added new ball
    (check-equal?
     (length (world-balls (world-after-n-ticks WORLD-2NEW-BALLS-10-TICK 116)))
     0
     (++ "world after 125 ticks(second new ball hits the bottom wall) + 1 tick "
         "should remove the second added new ball")))
   
   (test-case
    "Test #5"
    ;; world after 125 ticks(first new ball hits the bottom wall)
    ;;   + 6 ticks(3 seconds) + 3 ticks(extra) (here tick = .5s)
    ;; should not give a world at ready to serve state
    (check-equal?
     (world-ready-to-serve?
      (world-after-n-ticks WORLD-2NEW-BALLS-10-TICK (+ 118 (/ 3 SPEED ))))
     true
     (++ "The world should be in ready-to-serve state after 3 seconds of "
         "real time after all balls had collided bottom wall and disappeared "
         "after 125 tick")))
   
   
   ;; test for initial position of newly added ball
   
   (test-case
    "Test #6"
    ;velocity of new ball vy
    (check-equal? (ball-vy NEW-BALL) -9
                  " initial velocity along Y axis is -9 "))
   
   
   (test-case
    "Test #7"
    ;velocity of new ball vx
    (check-equal? (ball-vx NEW-BALL) 3
                  " initial velocity along X axis is 3 "))
   
   
   
   (test-case
    "Test #8"
    ;position of new ball y
    (check-equal? (ball-y NEW-BALL) 384
                  " initial position along Y axis is 384 "))
   
   
   (test-case
    "Test #9"
    ;position of new ball x
    (check-equal? (ball-x NEW-BALL) 330
                  " initial position along X axis is 330 "))
   
   
   
   (test-case
    "Test #10"
    ;Ball with negative velocity should not collide with racket
    (check-equal?
     (and ( = (ball-vy (first (world-balls WORLD-DRAG-2TICKS))) -9)
          ( = (ball-vy (second (world-balls WORLD-DRAG-2TICKS))) -9))
     #t
     " both the balls should not collide with racket "))
   
   
   
   (test-case
    "Test #11"
    ;Ball with positive velocity should  collide with racket
    (check-equal?
     (and ( = (ball-vy (first (world-balls WORLD-WITH-COLLISION))) -12)
          ( = (ball-vy (second (world-balls WORLD-WITH-COLLISION))) -12))
     #t
     " both the balls should collide with racket independently"))
   
   
   (test-case
    "Test #12"
    ;Racket's velocity should change to zero after collision
    (check-equal?
     (racket-vy (world-racket WORLD-WITH-COLLISION)) 0
     " racket's vy velocity should reset to zero after collision"))
   
   
   (test-case
    "Test #13 (was Test #12 from set03 q1)"
    ;; world after 43 ticks (ball hits y axis top) (391,3)
    (check-equal? (ball-y (first (world-balls
                                  (world-after-n-ticks WORLD-RALLY-STATE 43))))
                  3
                  "ball's position in y should be 3 after 43 ticks"))
   
   
   (test-case
    "Test #14 (was Test #20 from set03 q1)"
    ;; world after 115 ticks(ball hits the bottom wall)
    ;;   + 6 ticks(3 seconds) + 3 ticks(extra) (here tick = .5s)
    ;; should give a world at ready to serve state
    (check-equal?
     (world-ready-to-serve?
      (world-after-n-ticks WORLD-RALLY-STATE (+ 118 (/ 3 SPEED ))))
     true
     (++ "The world should be in ready-to-serve state after 3 seconds of "
         "real time the ball collides bottom wall after 115 tick")))
   
   (test-case
    "Test #15 (was Test #7 from set03 q2)"
    ;Racket should not move when it is selected
    (check-equal?
     (racket-y
      (world-racket
       (world-after-tick
        (world-after-mouse-event WORLD-RACKET-WITH-3SPEED
                                 335 388 BUTTON-DOWN))))
     384
     "Racket should not move when it is selected"))
   
   ))

(run-tests tests 'verbose)
