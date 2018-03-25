;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q1-bb) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;;#lang racket

(require rackunit)
(require rackunit/text-ui)
(require "q1.rkt")

;; Defining some constants
(define SPACE-BAR " ")
(define UP "up")
(define SPEED 0.5)
;;Initial world with 0.5 secs per tick
(define INITIAL-WORLD (initial-world SPEED))
;; World in a rally state
(define WORLD-RALLY-STATE (world-after-key-event
                           INITIAL-WORLD SPACE-BAR))

;; World with a racket with 3 speed in up direction after one tick.
(define WORLD-RACKET-WITH-3SPEED
  (world-after-key-event
   (world-after-key-event
    (world-after-key-event (world-after-tick WORLD-RALLY-STATE) UP) UP) UP))





;; World with a racket with 9 speed in up direction after one tick.
(define WORLD-RACKET-WITH-9SPEED
  (world-after-key-event
   (world-after-key-event
    (world-after-key-event
     (world-after-key-event
      (world-after-key-event
       (world-after-key-event WORLD-RACKET-WITH-3SPEED UP) UP) UP) UP) UP) UP))




;; world-after-n-ticks : World PosInt -> World
;; Given a state of a World and a positive integer n
;; Returns World after n number of ticks.
(define (world-after-n-ticks w n)
  (if(= n 0) w
     (world-after-n-ticks (world-after-tick w) (- n 1))))



;; World with a racket with 6 speed in up direction after 63 tick and at position (330,198).
(define WORLD-RACKET-WITH-6SPEED-63TICK
  (world-after-key-event
   (world-after-key-event
    (world-after-key-event (world-after-n-ticks WORLD-RACKET-WITH-3SPEED 62) UP) UP) UP))


(define tests
  (test-suite
   "q1"
   (test-case
    "Test #1"
    ;ball-x
    (check-equal? (ball-x (world-ball INITIAL-WORLD)) 330
                  "Initial position of the ball in x should be 330"))
   
   (test-case
    "Test #2"
    ;ball-y
    (check-equal? (ball-y (world-ball INITIAL-WORLD)) 384
                  "Initial position of the ball in y should be 384"))
   
   (test-case
    "Test #3"
    ;ball-vx
    (check-equal? (ball-vx (world-ball INITIAL-WORLD)) 0
                  "Initial velocity of the ball in x should be 0"))
   
   (test-case
    "Test #4"
    ;ball-vy
    (check-equal? (ball-vy (world-ball INITIAL-WORLD)) 0
                  "Initial position of the ball in y should be 0"))
   
   (test-case
    "Test #5"
    ;ball-vx rally state
    (check-equal? (ball-vx (world-ball
                            (world-after-tick
                             WORLD-RALLY-STATE))) 3
                                                  "Velocity of the ball in x during rally state should be 3"))
   
   (test-case
    "Test #6"
    ;ball-vy rally state
    (check-equal? (ball-vy (world-ball
                            (world-after-tick
                             WORLD-RALLY-STATE))) -9
                                                  "Velocity of the ball in y during rally state should be -9"))
   
   (test-case
    "Test #7"
    ;; world ready to serve
    (check-equal? (world-ready-to-serve? INITIAL-WORLD) true
                  "Initial world should be world-ready-to-serve-state"))
   
   (test-case
    "Test #8"
    ;; world ready to serve
    (check-equal? (world-ready-to-serve?
                   WORLD-RALLY-STATE) false
                                      "World-rally-state is not world-ready-to-serve-state"))
   
   (test-case
    "Test #9"
    ;; world after 32 ticks (x axis right side ) (424,96)
    (check-equal? (ball-x (world-ball
                           (world-after-n-ticks WORLD-RALLY-STATE 32))) 424
                                                                        "ball in x axis should be at 424 after 32 ticks"))
   
   (test-case
    "Test #10"
    ;; world after 32 ticks (x axis right side ) (424,96)
    (check-equal? (ball-vx (world-ball
                            (world-after-n-ticks WORLD-RALLY-STATE 32))) -3
                                                                         "ball's velocity in vx should be -3 after 32 ticks"))
   
   (test-case
    "Test #11"
    ;; world after 32 ticks (x axis right side ) (424,96)
    (check-equal? (ball-vy (world-ball
                            (world-after-n-ticks WORLD-RALLY-STATE 32))) -9
                                                                         "ball's velocity in vy should be -9 after 32 ticks"))
   
   (test-case
    "Test #12"
    ;; world after 43 ticks (ball hits y axis top) (391,3)
    (check-equal? (ball-y (world-ball
                           (world-after-n-ticks WORLD-RALLY-STATE 43))) 3
                                                                        "ball's position in y should be 3 after 43 ticks"))
   
   (test-case
    "Test #13"
    ;; world after 43 ticks (ball hits y axis top) (391,3)
    (check-equal? (ball-vx (world-ball
                            (world-after-n-ticks WORLD-RALLY-STATE 43))) -3
                                                                         "ball's velocity in vx should be -3 after 43 ticks"))
   
   (test-case
    "Test #14"
    ;; world after 43 ticks (ball hits y axis top) (391,3)
    (check-equal? (ball-vy (world-ball
                            (world-after-n-ticks WORLD-RALLY-STATE 43))) 9
                                                                         "ball's velocity in vy should be 9 after 43 ticks"))
   
   (test-case
    "Test #15"
    ;;  world after 64 ticks with racket in motion(colliding with the racket))
    (check-equal? (racket-y (world-racket
                             (world-after-n-ticks WORLD-RACKET-WITH-6SPEED-63TICK 1))) 192
                                                                                 "racket's position in y axis should be 192 after 64 ticks"))
   
   (test-case
    "Test #16"
    ;;  world after 64 ticks with racket in motion(colliding with the racket)))
    (check-equal? (racket-x (world-racket
                             (world-after-n-ticks WORLD-RACKET-WITH-6SPEED-63TICK 1))) 330
                                                                                 "racket's position in x axis should be 330 after 64 ticks"))
   
   (test-case
    "Test #17"
    ;;  world after 64 ticks with racket in motion(colliding with the racket))
    (check-equal? (racket-vy (world-racket
                              (world-after-n-ticks WORLD-RACKET-WITH-6SPEED-63TICK 1))) 0
                                                                                  "racket's velocity vy should be 0 after 64 ticks as collision takes place"))
   
   (test-case
    "Test #18"
    ;;  world after 65 ticks with racket in motion (after colliding with the racket)
    (check-equal? (ball-vy (world-ball
                            (world-after-n-ticks WORLD-RACKET-WITH-6SPEED-63TICK 2))) -15
                                                                                "ball's velocity in vy should be -15 after 65 ticks"))
   
   (test-case
    "Test #19"
    ;;  world after 65 ticks with racket in motion (after colliding with the racket)
    (check-equal? (ball-vx (world-ball
                            (world-after-n-ticks WORLD-RACKET-WITH-6SPEED-63TICK 2))) -3
                                                                                "ball's velocity in vx should be -3 after 65 ticks"))
   
   (test-case
    "Test #20"
    ;; world after 115 ticks(ball hits the bottom wall) + 6 ticks(3 seconds) + 1 tick (here tick = .5s) should give a world at ready to serve state
    (check-equal? (world-ready-to-serve? (world-after-n-ticks WORLD-RALLY-STATE (+ 116 (/ 3 SPEED )))) true
                  "The world should be in ready-to-serve state after 3 seconds of real time the ball collides bottom wall after 115 tick"))


   (test-case
    "Test #21"
    ;; world after 44 ticks(racket hits the top wall) + 6 ticks(3 seconds) + 1 tick (here tick = .5s) should give a world at ready to serve state
    (check-equal? (world-ready-to-serve? (world-after-n-ticks WORLD-RACKET-WITH-9SPEED (+ 45 (/ 3 SPEED )))) true
                  "The world should be in ready-to-serve state after 3 seconds of real time when the racket collides with top wall after 44 tick"))
   )
  )

(run-tests tests 'verbose)
