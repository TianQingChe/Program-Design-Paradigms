;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(require 2htdp/universe)
(require 2htdp/image)
(check-location "04" "q2.rkt")

(provide
 simulation
 initial-world
 world-ready-to-serve?
 world-after-tick
 world-after-key-event
 world-balls
 world-racket
 ball-x
 ball-y
 racket-x
 racket-y
 ball-vx
 ball-vy
 racket-vx
 racket-vy
 world-after-mouse-event
 racket-after-mouse-event
 racket-selected?)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; CONSTANTS
(define NEG-ONE -1)
(define ZERO 0)
(define ONE 1)
(define TWO 2)
(define THREE 3)
(define TRUE true)
(define FALSE false)

(define READY-VX 0)
(define READY-VY 0)
(define READY-X 330)
(define READY-Y 384)

(define COURT-WIDTH 425)
(define COURT-HEIGHT 649)
(define BALL-RADIUS 3)
(define BALL-SHAPE (circle BALL-RADIUS "solid" "black"))
(define RACKET-HSIDE 47)
(define RACKET-VSIDE 7)
(define RACKET-SHAPE
  (rectangle RACKET-HSIDE RACKET-VSIDE "solid" "green"))
(define MOUSE-SHAPE (circle 4 "solid" "blue"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; DATA DEFINITIONS

;; Court
(define WHITE-COURT (empty-scene COURT-WIDTH COURT-HEIGHT "white"))
(define YELLOW-COURT (empty-scene COURT-WIDTH COURT-HEIGHT "yellow"))

;; REPRESENTATION:
;; A Ball is represented as a (make-ball vx vy x y)
;; INTERPRETATION:
;; vx : Integer is how many pixels the ball moves on each tick in
;;      the x directions
;; vy : Integer is how many pixels the ball moves on each tick in 
;;      the y directions
;; x, y: NonNegInt the position of the center of the ball in 
;;               the scene 

;; IMPLEMENTATION:
(define-struct ball (vx vy x y))

;; CONSTRUCTOR TEMPLATE:
;; (make-ball Integer Integer NonNegInt NonNegInt)

;; OBSERVER TEMPLATE:
;; ball-fn : Ball -> ??
(define (ball-fn b)
  (...
   (ball-vx b)
   (ball-vy b)
   (ball-x b)
   (ball-y b)))

;; An BallList is represented as a list of Balls that are present in
;; the world

;; CONSTRUCTOR TEMPLATES:
;; empty
;; (cons b bl)
;; -- WHERE
;;    b  is a Ball
;;    bl is a BallList

;; OBSERVER TEMPLATE:

;; bl-fn : Inventory -> ??
;;(define (bl-fn bl)
;;  (cond
;;    [(empty? bl) ...]
;;    [else (...
;;            (ball-fn (first bl))
;;	    (bl-fn (rest bl)))]))

;; REPRESENTATION:
;; A Racket is represented as a (make-racket vx vy x y selected?)
;; INTERPRETATION:
;; vx : Integer is how many pixels the racket moves on each tick 
;;      in the x directions
;; vy : Integer is how many pixels the racket moves on each tick 
;;      in the y directions
;; x, y: NonNegInt the position of the center of the racket in the
;;       scene
;; selected?: Boolean describes whether or not the racket is selected
;; mouse-x: Integer is the x coordinate of mouse
;; mouse-y: Integer is the y coordiante of mouse
;; x-distance: Integer the distance between the x coordinate of 
;;                   racket and the mouse
;; y-distance: Integer the distance between the y coordinate of 
;;                   racket and the mouse

;; IMPLEMENTATION:
(define-struct racket (vx vy x y selected? mouse-x mouse-y d-x d-y))

;; CONSTRUCTOR TEMPLATE:
;; (make-racket Integer Integer NonNegInt NonNegInt Boolean Integer
;;                                     Integer Integer Integer)

;; OBSERVER TEMPLATE:
;; racket-fn : Racket -> ??
(define (racket-fn r)
  (...
   (racket-vx r)
   (racket-vy r)
   (racket-x r)
   (racket-y r)
   (racket-selected? r)
   (racket-mouse-x r)
   (racket-mouse-y r)
   (racket-d-x r)
   (racket-d-y r)))

;; A WorldState is represented as one of the following strings:
;; "ready" ： represents that the world is in a ready to
;;                     serve state
;; "rally" : represents that the world is in a rally state
;; "paused" : represents that the world is in a paused state
(define READY "ready to serve")
(define RALLY "rally")
(define PAUSED "paused")

;; REPRESENTATION
;; A World is represented as a
;; (make-world ball racket speed state tick-number)
;; INTEPRETATION：
;; balls    : BallList    a list of the balls that are present in the world
;; racket  : Racket   the racket in the world
;; speed   : Real     is the speed of the simulation of the world
;; state : WorldState is the state of the world
;; tick-number : NonNegInt the number of ticks of the world

;; IMPLEMENTATION:
(define-struct world (balls racket speed state tick-number))

;; CONSTRUCTOR TEMPLATE:
;; (make-world Ball Racket Real WorldState NonNegInt)

;; OBSERVER TEMPLATE:
;; world-fn : World -> ??
(define (world-fn w)
  (...
   (world-balls w)
   (world-racket w)
   (world-speed w)
   (world-state w)
   (world-tick-number w)))

 ;;; world-balls : World -> BallList
          ;;; GIVEN: a world
          ;;; RETURNS: a list of the balls that are present in the world
          ;;;     (but does not include any balls that have disappeared
          ;;;     by colliding with the back wall)

;; Examples of balls, for testing
(define READY-BALL
  (list (make-ball READY-VX READY-VY READY-X READY-Y)))
(define RALLY-BALL (cons (make-ball 3 -9 READY-X READY-Y) empty))

;; Examples of rackets, for testing
(define READY-RACKET (make-racket READY-VX READY-VY READY-X READY-Y
                                  FALSE -10 -10 -10 -10))

;; Examples of worlds, for testing
;; world at the ready-to-serve state
(define READY-WORLD-AT-1
  (make-world READY-BALL READY-RACKET ONE READY NEG-ONE))

(define READY-WORLD-AT-TICK-2
  (make-world READY-BALL READY-RACKET ONE READY -2))

;; world after rally state start
(define WORLD-AFTER-RALLY-START-AT-1
  (make-world RALLY-BALL READY-RACKET ONE RALLY -2))

;; the world with its ball colliding with the bottom wall at the 
;; next tick in rally state
(define BALL-BOTTOM-WORLD-AT-1
  (make-world empty READY-RACKET ONE RALLY
               NEG-ONE))

;; the world with its racket colliding with the front wall at the
;; next tick in rally state
(define RACKET-FRONT-WORLD-AT-1
  (make-world (list (make-ball 3 -9 100 100))
              (make-racket 0 -8 220 5 FALSE -10 -10 -10 -10)
               ONE RALLY NEG-ONE))

;; the world paused for ball colliding with the bottom wall
(define BALL-PAUSED-WORLD-AT-1
  (make-world empty
               READY-RACKET ONE PAUSED ZERO))

;; the world paused for racket colliding with the front wall
(define RACKET-PAUSED-WORLD-AT-1
  (make-world (list (make-ball ZERO ZERO 100 100))
              (make-racket ZERO ZERO 220 5 FALSE -10 -10 -10 -10)
              ONE PAUSED ZERO))

;; the world in a rally state without any collision
(define NOT-PAUSED-WORLD-AT-1
  (make-world (cons (make-ball 3 -9 100 300) empty)
              (make-racket ZERO -8 150 400 FALSE -10 -10 -10 -10)
               ONE RALLY NEG-ONE))

;; the world in a rally state after one tick of NOT-PAUSED-WORLD-AT-1
(define TICK-LATER-WORLD-AT-1
  (make-world (cons (make-ball 3 -9 103 291) empty)
              (make-racket ZERO -8 150 392 FALSE -10 -10 -10 -10)
              ONE RALLY NEG-ONE))

;; the world paused without ball and racket colliding with each other
(define PAUSED-WORLD-AT-1
  (make-world (list (make-ball ZERO ZERO 100 100))
              (make-racket ZERO ZERO 220 220 FALSE -10 -10 -10 -10)
              ONE PAUSED ZERO))

;; the world one tick later after PAUSED-WORLD-AT-1
(define TICK-LATER-PAUSED-WORLD-AT-1
  (make-world (list (make-ball ZERO ZERO 100 100))
              (make-racket ZERO ZERO 220 220 FALSE -10 -10 -10 -10)
              ONE PAUSED ONE))

;; the world at the end of its paused state
(define END-PAUSED-WORLD-AT-1
    (make-world (list (make-ball ZERO ZERO 100 100))
        (make-racket ZERO ZERO 220 220 FALSE -10 -10 -10 -10)
         ONE PAUSED (/ THREE ONE)))

;; the world with an empty balllist and tick -2
(define WORLD-WITH-NO-BALL-TICK-2
  (make-world
               empty
               READY-RACKET
               ONE
               RALLY
                -2))

;; the world with an empty balllist and tick -1
(define WORLD-WITH-NO-BALL-TICK-1
  (make-world
               empty
               READY-RACKET
               ONE
               RALLY
                -1))

;; the world at the first tick after rally state starts
(define WORLD-FIRST-START
  (make-world
               READY-BALL
               READY-RACKET
               ONE
               RALLY
                -2))

;; the world next to the first tick after rally state starts
(define WORLD-AFTER-FIRST-START
  (make-world
               (cons (make-ball 0 0 330 384) empty)
               READY-RACKET
               ONE
               RALLY
                NEG-ONE))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; FUNCTIONS

;;; Setting Functions

;;; simulation : PosReal -> World
;;; GIVEN: the speed of the simulation, in seconds per tick
;;;     (so larger numbers run slower)
;;; EFFECT: runs the simulation, starting with the initial world
;;; RETURNS: the final state of the world
;;; EXAMPLES:
;;;     (simulation 1) runs in super slow motion
;;;     (simulation 1/24) runs at a more realistic speed
(define (simulation speed)
  (big-bang (initial-world speed)
            (on-tick world-after-tick speed)
            (on-draw world-to-scene)
            (on-key world-after-key-event)
            (on-mouse world-after-mouse-event)))

;;; initial-world : PosReal -> World
;;; GIVEN: the speed of the simulation, in seconds per tick
;;;     (so larger numbers run slower)
;;; RETURNS: the ready-to-serve state of the world
;;; EXAMPLE: (initial-world 1) = READY-WORLD-AT-1
;;; DESIGN STRATEGY: Use constrcutor template for World
(define (initial-world s)
  (make-world
    READY-BALL READY-RACKET s "ready to serve" NEG-ONE))
(begin-for-test
  (check-equal?
   (initial-world 1)
   READY-WORLD-AT-1
   "The two world should have the same speed: 1."))
           
;;; world-to-scene : World -> Scene
;;; GIVEN:   a world
;;; RETURNS: a Scene that portrays the given world.
;;; EXAMPLE: (world-to-scene READY-WORLD-AT-1) should return a white
;;;           canvas with the ball and racket both at (330,384)
;;; DESIGN STRATEGY: Place ball and racket in turn.
(define (world-to-scene w)
    (if (string=? (world-state w) PAUSED)
     (scene-with-mouse
      (world-racket w)
      (scene-with-balls
        (world-balls w)
         (scene-with-racket
          (world-racket w)
           YELLOW-COURT)))
     (scene-with-mouse
      (world-racket w)
      (scene-with-balls
        (world-balls w)
         (scene-with-racket
          (world-racket w)
           WHITE-COURT)))))

(define IMAGE-OF-READY-WORLD-AT-1
  (place-image BALL-SHAPE READY-X READY-Y
    (place-image RACKET-SHAPE READY-X READY-Y
      WHITE-COURT)))
(define IMAGE-OF-PAUSED-WORLD-AT-1
  (place-image BALL-SHAPE 100 100
    (place-image RACKET-SHAPE 220 220
      YELLOW-COURT)))

(begin-for-test
  (check-equal?
   (world-to-scene READY-WORLD-AT-1)
   IMAGE-OF-READY-WORLD-AT-1
   "The scene of the world should be the same as the
      IMAGE-OF-READY-WORLD-AT-1")
  (check-equal?
   (world-to-scene PAUSED-WORLD-AT-1)
   IMAGE-OF-PAUSED-WORLD-AT-1
   "The scene of the world should be the same as the
      IMAGE-OF-PAUSED-WORLD-AT-1"))

;;; scene-with-mouse : World-mouse-x World-mouse-y Scene -> Scene
;;; RETURNS: a scene like the given one, but with the mouse painted
;;;          on it
;;; Example: (scene-with-mouse (make-racket READY-VX READY-VY 
;;;          READY-X READY-Y FALSE ZERO ZERO)) should return a white 
;;;           canvas with the mouse indication at (20, 20)
;;; DESIGN STRATEGY: Place the image of the mouse on an empty canvas 
;;;                  at the right position
(define (scene-with-mouse r s)
  (place-image
   MOUSE-SHAPE
   (racket-mouse-x r)
   (racket-mouse-y r)
   s))

(define MOUSE-IMAGE-FOR-TEST
  (place-image MOUSE-SHAPE 20 20 WHITE-COURT))
(begin-for-test
  (check-equal?
   (scene-with-mouse (make-racket 0 0 200 200 FALSE 20 20 180 180)
                     WHITE-COURT)
   MOUSE-IMAGE-FOR-TEST
   "The scene with the mouse should be the same as
    MOUSE-IMAGE-FOR-TEST"))

;;;  scene-with-balls : BallList Scene -> Scene
;;; RETURNS: a scene like the given one, but with the given list of 
;;;          balls painted on it
;;; Example: (scene-with-balls READY-BALL WHITE-COURT) should return a
;;;          white canvas with a ball at (330, 384)
;;; DESIGN STRATEGY: Place the image of the balls on an empty canvas 
;;;                   at the right position
(define (scene-with-balls bl s)
   (cond
    [(empty? bl) s]
    [else (place-image
           BALL-SHAPE
          (ball-x (first bl)) (ball-y (first bl))
           (scene-with-balls (rest bl) s))]))

(define BALL-IMAGE-AT-READY-WORLD
  (place-image BALL-SHAPE READY-X READY-Y WHITE-COURT))
(begin-for-test
  (check-equal?
   (scene-with-balls READY-BALL WHITE-COURT)
   BALL-IMAGE-AT-READY-WORLD
   "The scene with the ball should be the same as
    BALL-IMAGE-AT-READY-WORLD"))

;; scene-with-racket : Racket Scene -> Scene
;; RETURNS: a scene like the given one, but with the given racket
;;          painted on it
;;; Example: (scene-with-racket READY-RACKET WHITE-COURT) should
;;;          return a white canvas with the racket at (330, 384)
;;; DESIGN STRATEGY: Place the image of the racket on an empty canvas 
;;                   at the right position
(define (scene-with-racket r s)
  (place-image
    RACKET-SHAPE
    (racket-x r) (racket-y r)
    s))

(define RACKET-IMAGE-AT-READY-WORLD
  (place-image RACKET-SHAPE READY-X READY-Y WHITE-COURT))
(begin-for-test
  (check-equal?
   (scene-with-racket READY-RACKET WHITE-COURT)
   RACKET-IMAGE-AT-READY-WORLD
   "the scene with the racket should be the same as
    RACKET-IMAGE-AT-READY-WORLD"))
          
;;; world-ready-to-serve? : World -> Boolean
;;; GIVEN: a world
;;; RETURNS: true iff the world is in its ready-to-serve state
;;; DESIGN STRATEGY: Compare the world's state with READY state
(define (world-ready-to-serve? w)
  (string=? (world-state w) READY))
(begin-for-test
  (check-equal? (world-ready-to-serve? READY-WORLD-AT-1) TRUE
                "The world state should be ready to serve"))

;;; world-rally? : World -> Boolean
;;; GIVEN: a world
;;; RETURNS: true iff the world is in a rally state
;;; DESIGN STRATEGY: Compare the world's state with RALLY state
(define (world-rally? w)
  (string=? (world-state w) RALLY))
(begin-for-test
  (check-equal? (world-ready-to-serve? READY-WORLD-AT-1) TRUE
                "The world state should be rally"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Functions for World

;;; world-after-tick : World -> World
;;; GIVEN: any world that's possible for the simulation
;;; RETURNS: the world that should follow the given world
;;;          after a tick
;;; EXAMPLES:
;;; ball collides with the bottom wall:
;;;     (world-after-tick BALL-BOTTOM-WORLD-AT-1)
;;;                                         =BALL-PAUSED-WORLD-AT-1
;;; racket collides with the front wall:
;;;     (world-after-tick RACKET-FRONT-WORLD-AT-1)
;;;                                       =RACKET-PAUSED-WORLD-AT-1
;;; the world not in a paused state(just be paused, during paused or
;;;                                 just come back from pausing)
;;;     (world-after-tick NOT-PAUSED-WORLD-AT-1)
;;;                                       =TICK-LATER-WORLD-AT-1
;;; the world during the three seconds of pausing period
;;;     (world-after-tick PAUSED-WORLD-AT-1)
;;;                                     =TICK-LATER-PAUSED-WORLD-AT-1
;;; the world at the end of its paused state
;;;     (world-after-tick END-PAUSED-WORLD-AT-1)
;;;                                 =READY-WORLD-AT-1
;;; DESIGN STRATEGY: Divide into cases on tick-number and ball's
;;;                  collision with bottom wall and racket's collision
;;;                  with front wall
(define (world-after-tick w)
  (cond
        [(world-end-pause? w) (initial-world (world-speed w))]
        [(world-in-pause? w) (world-after-pause w)]
        [(world-rally-move? w) (make-rally-world w)]))
(begin-for-test
  (check-equal?
   (world-after-tick BALL-BOTTOM-WORLD-AT-1) BALL-PAUSED-WORLD-AT-1)
  (check-equal?
   (world-after-tick RACKET-FRONT-WORLD-AT-1)
    RACKET-PAUSED-WORLD-AT-1)
  (check-equal?
   (world-after-tick NOT-PAUSED-WORLD-AT-1)
    TICK-LATER-WORLD-AT-1)
  (check-equal?
   (world-after-tick PAUSED-WORLD-AT-1)
    TICK-LATER-PAUSED-WORLD-AT-1)
  (check-equal?
   (world-after-tick END-PAUSED-WORLD-AT-1)
    READY-WORLD-AT-1))

;;; world-rally-move? : World -> Boolean
;;; GIVEN:  a world
;;; RETURNS: true if the world is in a rally state and in move
(define (world-rally-move? w)
  (or (= (world-tick-number w) NEG-ONE) (= (world-tick-number w) -2)))
(begin-for-test
  (check-equal?
   (world-rally-move? WORLD-WITH-NO-BALL-TICK-2) TRUE))

;;; world-end-pause? : World -> Boolean
;;; GIVEN:  a world
;;; RETURNS: true if the world is in the end of its paused state
(define (world-end-pause? w)
  (= (world-tick-number w) (/ THREE (world-speed w))))

;;; world-in-pause? : World -> Boolean
;;; GIVEN:  a world
;;; RETURNS: true if the world is in paused state
(define (world-in-pause? w)
  (or (empty? (world-balls w))
      (racket-collide-front-wall? (world-racket w))
      (and (< (world-tick-number w) (/ THREE (world-speed w)))
           (> (world-tick-number w) NEG-ONE))))

;;; make-rally-world : World -> World
;;; GIVEN: a world in rally state without any collision
;;; RETURNS: the world after one tick
;;; DESIGN STRATEGY: Use constructor template for World
(define (make-rally-world w)
  (if (= (world-tick-number w) -2)
      (cond
        [(empty? (world-balls w)) w]
        [else (make-world
               (balls-after-tick
               (world-racket w) (world-balls w) (world-state w)
               (world-tick-number w))
               (racket-after-tick (world-racket w) (world-balls w)
                              (world-state w) (world-tick-number w))
               (world-speed w)
               (world-state w)
                NEG-ONE)])
      (cond
        [(empty? (world-balls w)) w]
        [else (make-world
               (balls-after-tick
               (world-racket w) (world-balls w) (world-state w)
               (world-tick-number w))
               (racket-after-tick (world-racket w) (world-balls w)
                              (world-state w) (world-tick-number w))
               (world-speed w)
               (world-state w)
               (world-tick-number w))])))
(begin-for-test
  (check-equal? (make-rally-world WORLD-FIRST-START)
                WORLD-AFTER-FIRST-START)
  (check-equal? (make-rally-world WORLD-WITH-NO-BALL-TICK-2)
                WORLD-WITH-NO-BALL-TICK-2)
  (check-equal? (make-rally-world WORLD-WITH-NO-BALL-TICK-1)
                WORLD-WITH-NO-BALL-TICK-1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Functions for Ball

;;; balls-after-tick:Racket Balls World-state World-tick-number-> Balls
;;; GIVEN: the state of a balllist bl, a racket r, world-state w-s of a
;;;        world
;;; RETURNS: the state of the given balls after a tick.
;;; EXAMPLES:
;;; ball collides with both front wall and right wall:
;;;      (balls-after-tick RACKET-NOT-COLLIDE-BALL
;;;                       BALL-COLLIDE-FRONT-RIGHT TRUE)
;;;                           =BALL-AFTER-COLLIDE-FRONT-RIGHT
;;; DESIGN STRATEGY: Use oberserver template for BallList
(define (balls-after-tick r bl w-s wtn)
  (cond
    [(empty? bl) empty]
    [else (if (ball-collides-bottom-wall? r (first bl) w-s wtn)
              (balls-after-tick r (rest bl) w-s wtn)
              (cons (ball-after-collide r (first bl) w-s wtn)
                (balls-after-tick r (rest bl) w-s wtn)))]))

;;; ball-after-collide : Racket Ball World-state 
;;;                                      World-tick-number -> Ball
;;; GIVEN: the state of a racket r,  a ball b, the world-state and 
;;;         world-tick-number of the world
;;; RETURNS: the ball after collide with walls or racket
;;; DESIGN STRATEGY: Divide into cases on ball's collision with
;;;                  walls or racket
(define (ball-after-collide r b w-s wtn)
  (cond
    [(and (ball-collides-front-wall? r b w-s wtn)
          (ball-collides-right-wall? r b w-s wtn))
     (ball-front-right-wall b)]
    [(and (ball-collides-front-wall? r b w-s wtn)
          (ball-collides-left-wall? r b w-s wtn))
     (ball-front-left-wall b)]
    [(ball-collides-front-wall? r b w-s wtn)
     (ball-after-collide-front b)]
    [(ball-collides-left-wall? r b w-s wtn)
     (ball-after-collide-left b)]
    [(ball-collides-right-wall? r b w-s wtn)
     (ball-after-collide-right b)]
    [(ball-collides-with-racket? r b w-s wtn)
     (ball-after-collide-racket b r)]
    [else (ball-not-collide b)]))


;;; TESTS
;;; Examples of balls and racket, for testing
(define RACKET-FOR-TEST (make-racket 0 5 100 100 FALSE -10 -10 -10                                   -10))

(define BALL-NO-COLLIDE (list (make-ball 3 -9 200 200)))
(define BALL-COLLIDE-RACKET (list (make-ball 3 9 90 103)))
(define BALL-COLLIDE-FRONT (list (make-ball 3 -9 220 5)))
(define BALL-COLLIDE-LEFT (list (make-ball -3 9 2 220)))
(define BALL-COLLIDE-RIGHT (list (make-ball 3 9 423 220)))
(define BALL-COLLIDE-BOTTOM (list (make-ball 3 9 200 645)))
(define BALL-COLLIDE-FRONT-RIGHT (list (make-ball 3 -9 423 5)))
(define BALL-COLLIDE-FRONT-LEFT (list (make-ball -3 -9 2 5)))

(define BALL-AFTER-NO-COLLIDE (list (make-ball 3 -9 203 191)))
(define BALL-AFTER-COLLIDE-WITH-RACKET (list (make-ball 3 -4 93 99)))
(define BALL-AFTER-COLLIDE-RIGHT-WALL (list (make-ball -3 9 424 229)))
(define BALL-AFTER-COLLIDE-LEFT-WALL (list (make-ball 3 9 1 229)))
(define BALL-AFTER-COLLIDE-FRONT-RIGHT (list (make-ball -3 9 424 4)))
(define BALL-AFTER-COLLIDE-FRONT-LEFT (list (make-ball 3 9 1 4)))
(define BALL-AFTER-COLLIDE-FRONT-WALL (list (make-ball 3 9 223 4)))
(begin-for-test
  (check-equal?
   (balls-after-tick RACKET-FOR-TEST BALL-COLLIDE-FRONT-RIGHT
                    RALLY NEG-ONE)
   BALL-AFTER-COLLIDE-FRONT-RIGHT)
  (check-equal?
   (balls-after-tick RACKET-FOR-TEST BALL-COLLIDE-FRONT-LEFT
                    RALLY NEG-ONE)
   BALL-AFTER-COLLIDE-FRONT-LEFT)
  (check-equal?
   (balls-after-tick RACKET-FOR-TEST BALL-COLLIDE-FRONT
                    RALLY NEG-ONE)
   BALL-AFTER-COLLIDE-FRONT-WALL)
  (check-equal?
   (balls-after-tick RACKET-FOR-TEST BALL-COLLIDE-LEFT
                    RALLY NEG-ONE)
   BALL-AFTER-COLLIDE-LEFT-WALL)
  (check-equal?
   (balls-after-tick RACKET-FOR-TEST BALL-COLLIDE-RIGHT
                    RALLY NEG-ONE)
   BALL-AFTER-COLLIDE-RIGHT-WALL)
  (check-equal?
   (balls-after-tick RACKET-FOR-TEST BALL-COLLIDE-RACKET
                    RALLY NEG-ONE)
   BALL-AFTER-COLLIDE-WITH-RACKET)
  (check-equal?
   (balls-after-tick RACKET-FOR-TEST BALL-NO-COLLIDE
                    RALLY NEG-ONE)
   BALL-AFTER-NO-COLLIDE)
  (check-equal?
   (balls-after-tick RACKET-FOR-TEST BALL-COLLIDE-BOTTOM
                     RALLY NEG-ONE)
   empty))

;;; ball-front-left-wall : Ball -> Ball
;;; GIVEN: a ball
;;; RETURNS: the ball whose new x, y component will be the negation
;;;          of its tentative x, y component and the vx, vy component
;;;          of its velocity is negated after a tick
;;; EXAMPLE: (ball-front-left-wall BALL-COLLIDE-FRONT-LEFT)
;;;                                  =BALL-AFTER-COLLIDE-FRONT-LEFT
;;; DESIGN STRATEGY: Use constructor template for Ball
(define (ball-front-left-wall b)
  (make-ball
   (- ZERO (ball-vx b))
   (- ZERO (ball-vy b))
   (- ZERO (+ (ball-x b) (ball-vx b)))
   (- ZERO (+ (ball-y b) (ball-vy b)))))
(begin-for-test
  (check-equal?
   (ball-front-left-wall (first BALL-COLLIDE-FRONT-LEFT))
    (first BALL-AFTER-COLLIDE-FRONT-LEFT)))

;;; ball-front-right-wall : Ball-> Ball
;;; GIVEN: a ball
;;; RETURNS: the ball's new x, y, vx, vy components all changed
;;;          according to the purpose statements of both
;;;          ball-after-collide-front and ball-after-collide-right
;;; EXAMPLE: (ball-front-right-wall BALL-COLLIDE-FRONT-RIGHT)
;;;                                  =BALL-AFTER-COLLIDE-FRONT-RIGHT
;;; DESIGN STRATEGY: Use constructor template for Ball
(define (ball-front-right-wall b)
  (make-ball
   (- ZERO (ball-vx b))
   (- ZERO (ball-vy b))
   (- COURT-WIDTH (- (+ (ball-x b) (ball-vx b)) COURT-WIDTH))
   (- ZERO (+ (ball-y b) (ball-vy b)))))
(begin-for-test
  (check-equal?
   (ball-front-right-wall (first BALL-COLLIDE-FRONT-RIGHT))
    (first BALL-AFTER-COLLIDE-FRONT-RIGHT)))

;;; ball-not-collide : Ball -> Ball
;;; GIVEN: a ball
;;; RETURNS: the ball without colliding with walls or racket after
;;;          a tick
;;; EXAMPLE: (ball-not-collide BALL-NO-COLLIDE)=BALL-AFTER-NO-COLLIDE
;;; DESIGN STRATEGY: Use constructor template for Ball
(define (ball-not-collide b)
  (make-ball
   (ball-vx b)
   (ball-vy b)
   (+ (ball-x b) (ball-vx b))
   (+ (ball-y b) (ball-vy b))))
(begin-for-test
  (check-equal?
   (ball-not-collide (first BALL-NO-COLLIDE)) (first BALL-AFTER-NO-COLLIDE)))

;;; ball-after-collide-front : Ball -> Ball
;;; GIVEN: a ball
;;; RETURNS: the ball whose new y component will be the negation of
;;;          its tentative y component and the vy component of its
;;;          velocity is negated after a tick
;;; EXAMPLE: (ball-after-collide-front BALL-COLLIDE-FRONT)
;;;                           =BALL-AFTER-COLLIDE-FRONT-WALL
;;; DESIGN STRATEGY: Use constructor template for Ball
(define (ball-after-collide-front b)
  (make-ball
   (ball-vx b)
   (- ZERO (ball-vy b))
   (+ (ball-x b) (ball-vx b))
   (- ZERO (+ (ball-y b) (ball-vy b)))))
(begin-for-test
  (check-equal?
   (ball-after-collide-front (first BALL-COLLIDE-FRONT))
                                 (first BALL-AFTER-COLLIDE-FRONT-WALL)))

;;; ball-after-collide-left : Ball -> Ball
;;; GIVEN: a ball
;;; RETURNS: the ball whose new x component will be the negation of
;;;          its tentative x component and the vx component of its
;;;          velocity is negated after a tick
;;; EXAMPLE: (ball-after-collide-left BALL-COLLIDE-LEFT)
;;;                                    =BALL-AFTER-COLLIDE-LEFT-WALL
;;; DESIGN STRATEGY: Use constructor template for Ball
(define (ball-after-collide-left b)
  (make-ball
   (- ZERO (ball-vx b))
   (ball-vy b)
   (- ZERO (+ (ball-x b) (ball-vx b)))
   (+ (ball-y b) (ball-vy b))))
(begin-for-test
  (check-equal?
   (ball-after-collide-left (first BALL-COLLIDE-LEFT))
                                   (first BALL-AFTER-COLLIDE-LEFT-WALL)))

;;; ball-after-collide-right: Ball -> Ball
;;; GIVEN: a ball
;;; RETURNS: the ball whose new x component will be 425 minus the
;;;          difference between tentative x component and 425 and
;;;          the vx component of its velocity is negated after a
;;;          tick
;;; EXAMPLE: (ball-after-collide-right BALL-COLLIDE-RIGHT)
;;;                                 =BALL-AFTER-COLLIDE-RIGHT-WALL
;;; DESIGN STRATEGY: Use constructor template for Ball
(define (ball-after-collide-right b)
  (make-ball
   (- ZERO (ball-vx b))
   (ball-vy b)
   (- COURT-WIDTH (- (+ (ball-x b) (ball-vx b)) COURT-WIDTH))
   (+ (ball-y b) (ball-vy b))))
(begin-for-test
  (check-equal?
   (ball-after-collide-right (first BALL-COLLIDE-RIGHT))
                                    (first BALL-AFTER-COLLIDE-RIGHT-WALL)))

;;; ball-after-collide-racket: Ball Racket-> Ball
;;; GIVEN: a ball and a Racket in a rally-state world
;;; RETURNS: the ball after colliding with the racket
;;; EXAMPLE: (ball-after-collide-racket BALL-COLLIDE-RACKET
;;;          RACKET-FOR-TEST)
;;;                           =BALL-AFTER-COLLIDE-WITH-RACKET
;;; DESIGN STRATEGY: Use constructor template for Ball
(define (ball-after-collide-racket b r)
  (make-ball
   (ball-vx b)
   (- (racket-vy r) (ball-vy b))
   (+ (ball-x b) (ball-vx b))
   (+ (ball-y b) (- (racket-vy r) (ball-vy b)))))
(begin-for-test
  (check-equal?
   (ball-after-collide-racket (first BALL-COLLIDE-RACKET) RACKET-FOR-TEST)
                                    (first BALL-AFTER-COLLIDE-WITH-RACKET)))

;;; path-x-at-racket-vy : Racket-y Ball -> Real
;;; GIVEN: the y coordinate of a racket after a tick and a ball b
;;;        in a rally-state world
;;; RETURNS: the x coordinate when the y coordinate of ball path
;;;          during two ticks is same as racket-y
;;; EXAMPLE: (path-x-at-racket-vy 105 (make-ball 3 -9 90 110))
;;;                          = (/ 275 3)
;;; DESIGN STRATEGY: Transcribe formula
(define (path-x-at-racket-y ry b)
  (if (= (ball-vy b) 0)
      (+ (ball-x b) (ball-vx b))
      (+ (ball-x b)
        (/ (* (- ry (ball-y b))
           (ball-vx b))
           (ball-vy b)))))
(begin-for-test
  (check-equal? (path-x-at-racket-y 105 (make-ball 3 -9 90 110))
   (/ 275 3))
  (check-equal? (path-x-at-racket-y 105 (make-ball 5 0 90 110))
   95))

;;; ball-collides-with-racket? : Racket Ball World-state 
;;;                                      World-tick-number -> Boolean
;;; GIVEN: the state of a racket r,  a ball b, the world-state and 
;;         world-tick-number of the world
;;; RETURNS: true if the ball collides with the racket
;;; EXAMPLE: (ball-collides-with-racket? RACKET-FOR-TEST
;;;           BALL-COLLIDE-RACKET RALLY) = TRUE
;;;          (ball-collides-with-racket? RACKET-FOR-TEST
;;;           BALL-COLLIDE-RIGHT RALLY) = FALSE
;;; DESIGN STRATEGY: Use math principle for two line's intersection
(define (ball-collides-with-racket? r b w-s wtn)
   (and (string=? w-s RALLY) (> wtn -2) (>= (ball-vy b) 0)
        (> (path-x-at-racket-y (+ (racket-y r) (racket-vy r)) b)
          (- (racket-x r) (/ RACKET-HSIDE TWO)))
        (< (path-x-at-racket-y (+ (racket-y r) (racket-vy r)) b)
          (+ (racket-x r) (/ RACKET-HSIDE TWO)))
        (>= (path-x-at-racket-y (+ (racket-y r) (racket-vy r)) b)
                (min (ball-x b) (+ (ball-x b) (ball-vx b))))
        (<= (path-x-at-racket-y (+ (racket-y r) (racket-vy r)) b)
                (max (ball-x b) (+ (ball-x b) (ball-vx b))))))
(begin-for-test
  (check-equal? (ball-collides-with-racket? RACKET-FOR-TEST
                 (first BALL-COLLIDE-RACKET) RALLY NEG-ONE) TRUE)
  (check-equal? (ball-collides-with-racket? RACKET-FOR-TEST
                 (first BALL-COLLIDE-RIGHT) RALLY NEG-ONE) FALSE))

;;; balls-collides-with-racket? : BallList Racket World-state 
;;;                                      World-tick-number -> BallList
;;; GIVEN: the state of a racket r,  a balllist bl, the world-state and 
;;;         world-tick-number of the world
;;; RETURNS: true if a ball of the balllist collides with the racket
;;; DESIGN STRATEGY: Use observer template for BallList
(define (balls-collides-with-racket? r bl w-s wtn)
  (cond
    [(empty? bl) FALSE]
    [else (if (ball-collides-with-racket? r (first bl) w-s wtn)
              TRUE
              (balls-collides-with-racket? r (rest bl) w-s wtn))]))

;;; ball-collides-front-wall? : Ball Racket World-state 
;;;                                      World-tick-number -> Boolean
;;; GIVEN: the state of a racket r,  a ball b, the world-state and 
;;         world-tick-number of the world
;;; RETURNS: true if the ball's tentative new position lies outside  
;;;          the front wall of the court and does not collides with 
;;;          the racket
;;; EXAMPLE: (ball-collides-front-wall? RACKET-FOR-TEST
;;;                                 BALL-COLLIDE-FRONT TRUE) = TRUE
;;;          (ball-collides-front-wall? RACKET-FOR-TEST
;;;                                 BALL-COLLIDE-RIGHT TRUE) = FALSE
;;; DESIGN STRATEGY: Compare ball's tentative y component with 0
(define (ball-collides-front-wall? r b w-s wtn)
  (and (not (ball-collides-with-racket? r b w-s wtn))
       (< (+ (ball-y b) (ball-vy b)) ZERO)))
(begin-for-test
  (check-equal? (ball-collides-front-wall? RACKET-FOR-TEST
                           (first BALL-COLLIDE-FRONT) RALLY NEG-ONE) TRUE)
  (check-equal? (ball-collides-front-wall? RACKET-FOR-TEST
                           (first BALL-COLLIDE-RIGHT) RALLY NEG-ONE) FALSE))

;;; ball-collides-bottom-wall? : Ball Racket World-state 
;;;                                      World-tick-number -> Boolean
;;; GIVEN: the state of a racket r,  a ball b, the world-state and 
;;         world-tick-number of the world
;;; RETURNS: true if the ball's tentative new position lies outside  
;;;          the bottom wall of the court and does not collides 
;;;          with  the racket
;;; EXAMPLE: (ball-collides-bottom-wall? RACKET-FOR-TEST
;;;                                 BALL-COLLIDE-BOTTOM TRUE)=FALSE
;;;          (ball-collides-bottom-wall? RACKET-FOR-TEST
;;;                                 BALL-COLLIDE-RIGHT TRUE)=FALSE
;;; DESIGN STRATEGY: Compare ball's tentative y component with
;;;                  COURT-HEIGHT
(define (ball-collides-bottom-wall? r b w-s wtn)
  (and (not (ball-collides-with-racket? r b w-s wtn))
       (> (+ (ball-y b) (ball-vy b)) COURT-HEIGHT)))
(begin-for-test
  (check-equal? (ball-collides-bottom-wall? RACKET-FOR-TEST
                             (first BALL-COLLIDE-BOTTOM) RALLY NEG-ONE) TRUE)
  (check-equal? (ball-collides-bottom-wall? RACKET-FOR-TEST
                             (first BALL-COLLIDE-RIGHT) RALLY NEG-ONE) FALSE))

;;; ball-collides-left-wall? : Ball Racket World-state 
;;;                                      World-tick-number -> Boolean
;;; GIVEN: the state of a racket r,  a ball b, the world-state and 
;;         world-tick-number of the world
;;; RETURNS: true if the ball's tentative new position lies outside  
;;;          the left wall of the court and does not collides with 
;;;          the racket
;;; EXAMPLE: (ball-collides-left-wall? RACKET-FOR-TEST
;;;                                 BALL-COLLIDE-LEFT TRUE) = FALSE
;;;          (ball-collides-left-wall? RACKET-FOR-TEST
;;;                                 BALL-COLLIDE-RIGHT TRUE) = FALSE
;;; DESIGN STRATEGY：Compare ball's tentative x component with 0
(define (ball-collides-left-wall? r b w-s wtn)
  (and (not (ball-collides-with-racket? r b w-s wtn))
       (< (+ (ball-x b) (ball-vx b)) ZERO)))

;;; ball-collides-right-wall? : Ball Racket World-state 
;;;                                      World-tick-number -> Boolean
;;; GIVEN: the state of a racket r,  a ball b, the world-state and 
;;         world-tick-number of the world
;;; RETURNS: true if the ball's tentative new position lies outside  
;;;          the right wall of the court and does not collides with 
;;;          the racket
;;; EXAMPLE: (ball-collides-right-wall? RACKET-FOR-TEST
;;;                                 BALL-COLLIDE-RIGHT TRUE) = TRUE
;;;          (ball-collides-right-wall? RACKET-FOR-TEST
;;;                                 BALL-COLLIDE-LEFT TRUE) = FALSE
;;; DESIGN STRATEGY: Compare ball's tentative x component with
;;;                  COURT-WIDTH
(define (ball-collides-right-wall? r b w-s wtn)
  (and (not (ball-collides-with-racket? r b w-s wtn))
       (> (+ (ball-x b) (ball-vx b)) COURT-WIDTH)))
(begin-for-test
  (check-equal? (ball-collides-right-wall? RACKET-FOR-TEST
                              (first BALL-COLLIDE-RIGHT) RALLY NEG-ONE) TRUE)
  (check-equal? (ball-collides-right-wall? RACKET-FOR-TEST
                              (first BALL-COLLIDE-LEFT) RALLY NEG-ONE) FALSE))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Functions for Racket

;;; racket-after-tick : Racket Ball World-state World-tick-number
;;;                                                        -> Racket
;;; GIVEN: a racket r, a ball b and the world state w-s,
;;;        world-tick-number wtn
;;; RETURNS: the state of the given racket after a tick.
;;; EXAMPLES: as the tests below
;;; DESIGN STRATEGY: Divide into cases on racket's collision with
;;;                  ball and walls
(define (racket-after-tick r bl w-s wtn)
   (cond
     [(and
       (balls-collides-with-racket? r bl w-s wtn) (< (racket-vy r) ZERO))
      (racket-after-collide-ball r)]
     [(and (racket-collide-left-wall? r)(racket-collide-bottom-wall? r))
      (racket-collide-left-bottom r)]
     [(and (racket-collide-right-wall? r) (racket-collide-bottom-wall? r))
      (racket-collide-right-bottom r)]
     [(racket-collide-left-wall? r) (racket-after-collide-left r)]
     [(racket-collide-right-wall? r) (racket-after-collide-right r)]
     [(racket-collide-bottom-wall? r) (racket-after-collide-bottom r)]
     [else (racket-not-collide r)]))

;;; TESTS
;;; Examples of rackets and ball, for testing
(define BALL-FOR-TEST (list (make-ball -3 9 102 89)))

(define RACKET-NO-COLLIDE (make-racket 0 5 200 200 FALSE -10 -10 -10 -10))
(define RACKET-COLLIDE-BALL (make-racket 0 -5 100 100 FALSE -10 -10 -10 -10))
(define RACKET-COLLIDE-LEFT (make-racket -5 0 2 100 FALSE -10 -10 -10 -10))
(define RACKET-COLLIDE-RIGHT (make-racket 5 0 423 100 FALSE -10 -10 -10 -10))
(define RACKET-COLLIDE-FRONT (make-racket 0 -5 100 2 FALSE -10 -10 -10 -10))
(define RACKET-COLLIDE-BOTTOM (make-racket 0 5 100 646 FALSE -10 -10 -10 -10
                                           ))
(define RACKET-COLLIDE-LEFT-BOTTOM (make-racket -5 5 2 646 FALSE -10 -10 -10
                                                -10))
(define RACKET-COLLIDE-RIGHT-BOTTOM (make-racket 5 5 423 646 FALSE
                                                 -10 -10 -10 -10))

(define RACKET-AFTER-NO-COLLIDE (make-racket 0 5 200 205 FALSE -10 -10 -10 -10))
(define RACKET-AFTER-COLLIDE-WITH-BALL (make-racket 0 0 100 95
                                                    FALSE -10 -10 -10 -10))
(define RACKET-AFTER-COLLIDE-WITH-LEFT (make-racket -5 0 24 100
                                                    FALSE -10 -10 -10 -10))
(define RACKET-AFTER-COLLIDE-WITH-RIGHT (make-racket 5 0 401 100
                                                     FALSE -10 -10 -10 -10))
(define RACKET-AFTER-COLLIDE-WITH-BOTTOM (make-racket 0 0 100 649
                                                     FALSE -10 -10 -10 -10))
(define RACKET-AFTER-COLLIDE-LEFT-BOTTOM (make-racket -5 5 24 649
                                                     FALSE -10 -10 -10 -10))
(define RACKET-AFTER-COLLIDE-RIGHT-BOTTOM (make-racket 5 5 401 649
                                                     FALSE -10 -10 -10 -10))

(begin-for-test
  (check-equal?
   (racket-after-tick RACKET-COLLIDE-BALL BALL-FOR-TEST RALLY NEG-ONE)
    RACKET-AFTER-COLLIDE-WITH-BALL)
  (check-equal?
   (racket-after-tick RACKET-COLLIDE-LEFT-BOTTOM BALL-FOR-TEST RALLY NEG-ONE)
    RACKET-AFTER-COLLIDE-LEFT-BOTTOM)
  (check-equal?
   (racket-after-tick RACKET-COLLIDE-RIGHT-BOTTOM BALL-FOR-TEST RALLY NEG-ONE)
    RACKET-AFTER-COLLIDE-RIGHT-BOTTOM)
  (check-equal?
   (racket-after-tick RACKET-COLLIDE-LEFT BALL-FOR-TEST RALLY NEG-ONE)
    RACKET-AFTER-COLLIDE-WITH-LEFT)
  (check-equal?
   (racket-after-tick RACKET-COLLIDE-RIGHT BALL-FOR-TEST RALLY NEG-ONE)
    RACKET-AFTER-COLLIDE-WITH-RIGHT)
  (check-equal?
   (racket-after-tick RACKET-COLLIDE-BOTTOM BALL-FOR-TEST RALLY NEG-ONE)
    RACKET-AFTER-COLLIDE-WITH-BOTTOM)
  (check-equal?
   (racket-after-tick RACKET-NO-COLLIDE BALL-FOR-TEST RALLY NEG-ONE)
    RACKET-AFTER-NO-COLLIDE))

;;; racket-collide-left-bottom ：Racket -> Racket
;;; GIVEN: a Racket r
;;; RETURNS: the racket whose x component is adjusted to keep the
;;;          racket touching the left wall and the bottom wall and
;;;          inside the court
;;; DESIGN STRATEGY: Use constructor template for Racket
(define (racket-collide-left-bottom r)
  (make-racket
   (racket-vx r)
   (racket-vy r)
   (ceiling (/ RACKET-HSIDE TWO))
   COURT-HEIGHT
   (racket-selected? r) (racket-mouse-x r) (racket-mouse-y r) 
        (racket-d-x r) (racket-d-y r)))

(begin-for-test
  (check-equal?
   (racket-collide-left-bottom RACKET-COLLIDE-LEFT-BOTTOM)
   RACKET-AFTER-COLLIDE-LEFT-BOTTOM))

;;; racket-collide-right-bottom :Racket -> Racket
;;; GIVEN: a Racket r
;;; RETURNS: the racket whose x component is adjusted to keep the
;;;          racket touching the right wall and the bottom wall and
;;;          inside the court
;;; DESIGN STRATEGY: Use constructor template for Racket
(define (racket-collide-right-bottom r)
  (make-racket
   (racket-vx r)
   (racket-vy r)
   (floor (- COURT-WIDTH (/ RACKET-HSIDE TWO)))
   COURT-HEIGHT
   (racket-selected? r) (racket-mouse-x r) (racket-mouse-y r) 
        (racket-d-x r) (racket-d-y r)))

(begin-for-test
  (check-equal?
   (racket-collide-right-bottom RACKET-COLLIDE-RIGHT-BOTTOM)
   RACKET-AFTER-COLLIDE-RIGHT-BOTTOM))

;;; racket-not-collide : Racket -> Racket
;;; GIVEN: a Racket r
;;; RETURNS: the racket without colliding with walls or ball after a
;;;          tick
;;; DESIGN STRATEGY: Use constructor template for Racket
(define (racket-not-collide r)
  (if (racket-selected? r)
      (make-racket
        (racket-vx r)
        (racket-vy r)
        (racket-x r)
        (racket-y r) 
        (racket-selected? r) (racket-mouse-x r) (racket-mouse-y r) 
        (racket-d-x r) (racket-d-y r))
      (make-racket
        (racket-vx r)
        (racket-vy r)
        (+ (racket-x r) (racket-vx r))
        (+ (racket-y r) (racket-vy r))
        (racket-selected? r) (racket-mouse-x r) (racket-mouse-y r) 
        (racket-d-x r) (racket-d-y r))))

(begin-for-test
  (check-equal?
   (racket-not-collide RACKET-NO-COLLIDE)
   RACKET-AFTER-NO-COLLIDE)
  (check-equal?
   (racket-not-collide RACKET-SELECTED)
   RACKET-AFTER-SELECTED))
(define RACKET-SELECTED
  (make-racket 0 5 200 200 TRUE -10 -10 -10 -10))
(define RACKET-AFTER-SELECTED
  (make-racket 0 5 200 200 TRUE -10 -10 -10 -10))

;;; racket-after-collide-ball : Racket -> Racket
;;; GIVEN: a Racket r
;;; RETURNS: the racket with its vy component being zero
;;; DESIGN STRATEGY: Use constructor template for Racket
(define (racket-after-collide-ball r)
  (make-racket
        (racket-vx r)
        ZERO
        (+ (racket-x r) (racket-vx r))
        (+ (racket-y r) (racket-vy r))
        (racket-selected? r) (racket-mouse-x r) (racket-mouse-y r) 
        (racket-d-x r) (racket-d-y r)))
(begin-for-test
  (check-equal?
   (racket-after-collide-ball RACKET-COLLIDE-BALL)
   RACKET-AFTER-COLLIDE-WITH-BALL))

;;; racket-after-collide-left : Racket -> Racket
;;; GIVEN: a racket
;;; RETURNS: the racket whose x component is adjusted to keep the
;;;          racket touching the left wall and inside the court
;;; DESIGN STRATEGY: Use constructor template for Racket
(define (racket-after-collide-left r)
  (make-racket
   (racket-vx r)
   (racket-vy r)
   (ceiling (/ RACKET-HSIDE TWO))
   (+ (racket-y r) (racket-vy r))
   (racket-selected? r) (racket-mouse-x r) (racket-mouse-y r) 
        (racket-d-x r) (racket-d-y r)))
(begin-for-test
  (check-equal?
   (racket-after-collide-left RACKET-COLLIDE-LEFT)
   RACKET-AFTER-COLLIDE-WITH-LEFT))

;;; racket-after-collide-right : Racket -> Racket
;;; GIVEN: a racket
;;; RETURNS: the racket whose x component is adjusted to keep the
;;;          racket touching the right wall and inside the court
;;; DESIGN STRATEGY: Use constructor template for Racket
(define (racket-after-collide-right r)
  (make-racket
   (racket-vx r)
   (racket-vy r)
   (floor (- COURT-WIDTH (/ RACKET-HSIDE TWO)))
   (+ (racket-y r) (racket-vy r))
   (racket-selected? r) (racket-mouse-x r) (racket-mouse-y r) 
        (racket-d-x r) (racket-d-y r)))
(begin-for-test
  (check-equal?
   (racket-after-collide-right RACKET-COLLIDE-RIGHT)
   RACKET-AFTER-COLLIDE-WITH-RIGHT))

;;; racket-after-collide-bottom : Racket -> Racket
;;; GIVEN: a racket
;;; RETURNS: the racket whose x component is adjusted to keep the
;;;          racket touching the bottom wall and inside the court
;;; DESIGN STRATEGY: Use constructor template for Racket
(define (racket-after-collide-bottom r)
  (make-racket
   (racket-vx r)
   ZERO
   (+ (racket-x r) (racket-vx r))
   COURT-HEIGHT
   (racket-selected? r) (racket-mouse-x r) (racket-mouse-y r) 
        (racket-d-x r) (racket-d-y r)))
(begin-for-test
  (check-equal?
   (racket-after-collide-bottom RACKET-COLLIDE-BOTTOM)
   RACKET-AFTER-COLLIDE-WITH-BOTTOM))

;;; racket-collide-front-wall? : Racket -> Boolean
;;; GIVEN: a racket r
;;; RETURNS: true if any part of the 47-pixel line segment of the
;;;          racket extends outside the front of the court
;;; DESIGN STRATEGY: Compare racket's tentative new y component with
;;;                  0
(define (racket-collide-front-wall? r)
  (< (+ (racket-y r) (racket-vy r)) ZERO))
(begin-for-test
  (check-equal? (racket-collide-front-wall? RACKET-COLLIDE-FRONT)
                true)
  (check-equal? (racket-collide-front-wall? RACKET-NO-COLLIDE)
                false))

;;; racket-collide-left-wall? : Racket -> Boolean
;;; GIVEN: a racket r
;;; RETURNS: true if any part of the 47-pixel line segment of the
;;;          racket extends outside the left of the court
;;; DESIGN STRATEGY: Compare racket's tentative new x component with
;;;                  0
(define (racket-collide-left-wall? r)
  (< (+ (- (racket-x r) (/ RACKET-HSIDE TWO)) (racket-vx r)) ZERO))
(begin-for-test
  (check-equal? (racket-collide-left-wall? RACKET-COLLIDE-LEFT)
                true)
  (check-equal? (racket-collide-left-wall? RACKET-NO-COLLIDE)
                false))

;;; racket-collide-right-wall? : Racket -> Boolean
;;; GIVEN: a racket r
;;; RETURNS: true if any part of the 47-pixel line segment of the
;;;          racket extends outside the right of the court
;;; DESIGN STRATEGY: Compare racket's tentative new x component with
;;;                  COURT-WIDTH
(define (racket-collide-right-wall? r)
  (> (+ (racket-x r) (/ RACKET-HSIDE TWO) (racket-vx r)) COURT-WIDTH))
(begin-for-test
  (check-equal? (racket-collide-right-wall? RACKET-COLLIDE-RIGHT)
                true)
  (check-equal? (racket-collide-right-wall? RACKET-NO-COLLIDE)
                false))

;;; racket-collide-bottom-wall? : Racket -> Boolean
;;; GIVEN: a racket r
;;; RETURNS：true if any part of the 47-pixel line segment of the
;;;          racket extends outside the bottom of the court
;;; DESIGN STRATEGY: Compare racket's tentative new y component with
;;;                  COURT-HEIGHT
(define (racket-collide-bottom-wall? r)
  (> (+ (racket-y r) (racket-vy r)) COURT-HEIGHT))
(begin-for-test
  (check-equal? (racket-collide-bottom-wall? RACKET-COLLIDE-BOTTOM)
                true)
  (check-equal? (racket-collide-bottom-wall? RACKET-NO-COLLIDE)
                false))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Functions for Key Event

;;; world-after-key-event : World KeyEvent -> World
;;; GIVEN: a world and a key event
;;; RETURNS: the world that should follow the given world
;;;     after the given key event
;;; DESIGN STRATEGY: Divide into cases on keyevent and state of world
(define (world-after-key-event w kev)
  (cond
    [(ready-to-rally? w kev) (world-after-rally-start w)]
    [(rally-to-pause? w kev) (world-after-pause w)]
    [(vx-decrease? w kev) (world-after-vx-decrease w)]
    [(vx-increase? w kev) (world-after-vx-increase w)]
    [(vy-decrease? w kev) (world-after-vy-decrease w)]
    [(vy-increase? w kev) (world-after-vy-increase w)]
    [(add-new-ball? w kev) (world-after-add-new-ball w)]
    [else w]))
;;; TESTS
;;; Exampels of world, for testing
(define RALLY-WORLD-AT-1
  (make-world (cons (make-ball 3 -9 100 100) empty)
              (make-racket 0 3 220 220 FALSE -10 -10 -10 -10)
              ONE "rally" NEG-ONE))
(define  WORLD-AFTER-ADD-BALL-AT-1
  (make-world (cons (make-ball 3 -9 330 384)
                    (cons (make-ball 3 -9 100 100) empty))
              (make-racket 0 3 220 220 FALSE -10 -10 -10 -10)
              ONE "rally" NEG-ONE))
(define RACKET-VX-DECREASE-WORLD-AT-1
  (make-world (cons (make-ball 3 -9 100 100) empty)
              (make-racket -1 3 220 220 FALSE -10 -10 -10 -10)
              ONE "rally" NEG-ONE))
(define RACKET-VX-INCREASE-WORLD-AT-1
  (make-world (cons (make-ball 3 -9 100 100) empty)
              (make-racket 1 3 220 220 FALSE -10 -10 -10 -10)
              ONE "rally" NEG-ONE))
(define RACKET-VY-DECREASE-WORLD-AT-1
  (make-world (cons (make-ball 3 -9 100 100) empty)
              (make-racket 0 2 220 220 FALSE -10 -10 -10 -10)
              ONE "rally" NEG-ONE))
(define RACKET-VY-INCREASE-WORLD-AT-1
  (make-world (cons (make-ball 3 -9 100 100) empty)
              (make-racket 0 4 220 220 FALSE -10 -10 -10 -10)
              ONE "rally" NEG-ONE))
(begin-for-test
  (check-equal?
   (world-after-key-event READY-WORLD-AT-1 " ")
    WORLD-AFTER-RALLY-START-AT-1)
  (check-equal?
   (world-after-key-event RALLY-WORLD-AT-1 " ")
    PAUSED-WORLD-AT-1)
  (check-equal?
   (world-after-key-event RALLY-WORLD-AT-1 "left")
    RACKET-VX-DECREASE-WORLD-AT-1)
  (check-equal?
   (world-after-key-event RALLY-WORLD-AT-1 "right")
    RACKET-VX-INCREASE-WORLD-AT-1)
  (check-equal?
   (world-after-key-event RALLY-WORLD-AT-1 "up")
    RACKET-VY-DECREASE-WORLD-AT-1)
  (check-equal?
   (world-after-key-event RALLY-WORLD-AT-1 "down")
    RACKET-VY-INCREASE-WORLD-AT-1)
  (check-equal?
   (world-after-key-event RALLY-WORLD-AT-1 "b")
   WORLD-AFTER-ADD-BALL-AT-1)
  (check-equal?
   (world-after-key-event READY-WORLD-AT-1 "r")
    (make-world
     (list (make-ball 0 0 330 384))
     (make-racket 0 0 330 384 FALSE -10 -10 -10 -10)
     ONE READY NEG-ONE)))

;;; add-new-ball? : World KeyEvent -> Boolean
;;; GIVEN: a world and a key event
;;; RETURNS: true iff the Key pressed is "b"  and the world is
;;;          currently in a rally-state
;;; DESIGN STRATEGY: Cases on keyevents and the state of world
(define (add-new-ball? w ke)
  (and (key=? ke "b") (world-rally? w)))

;;; rally-to-pause? : World KeyEvent -> Boolean
;;; GIVEN: a world and a key event
;;; RETURNS: true iff the Key pressed is space bar  and the world is
;;;          currently in a rally-state
;;; DESIGN STRATEGY: Cases on keyevents and the state of world
(define (rally-to-pause? w ke)
  (and (key=? ke " ") (world-rally? w)))

;;; world-after-pause : World -> World
;;; GIVEN : a world
;;; RETURNS: the world in a pause state the ball and racket do not
;;;          move, and the background color of the court changes from
;;;          white to yellow
;;; DESIGN STRATEGY: Use constructor template for World
(define (world-after-pause w)
  (make-world
  (balls-after-pause (world-balls w))
  (make-racket
    ZERO ZERO (racket-x (world-racket w)) (racket-y (world-racket w))
    FALSE -10 -10 -10 -10)
  (world-speed w)
  PAUSED
  (+ (world-tick-number w) ONE)))

;;; world-after-add-new-ball : World -> World
;;; GIVEN : a world
;;; RETURNS: the world after add a new ball
;;; DESIGN STRATEGY: Use constructor template for World
(define (world-after-add-new-ball w)
  (make-world
   (cons (make-ball 3 -9 330 384) (world-balls w))
   (world-racket w)
   (world-speed w)
   (world-state w)
   (world-tick-number w)))

;;; balls-after-pause : BallList -> BallList
;;; GIVEN: a balllist
;;; RETURNS: the balllist with all its ball paused
;;; DESIGN STRATEGY: Use oberserver template for BallList
(define (balls-after-pause bl)
  (cond
    [(empty? bl) empty]
    [else
     (cons (make-paused-ball (first bl))
           (balls-after-pause (rest bl)))]))

;;; make-paused-ball : Ball -> Ball
;;; GIVEN: a ball
;;; RETURNS：the ball paused
;;; DESIGN STRATEGY: Use constructor template for Ball
(define (make-paused-ball b)
  (make-ball
    ZERO ZERO (ball-x b) (ball-y b)))

;;; ready-to-rally? : World KeyEvent -> Boolean
;;; GIVEN: a world and a key event
;;; RETURNS: true iff the Key pressed is space bar and the world is
;;;          currently in a ready-to-serve state
;;; DESIGN STRATEGY: Cases on keyevents and the state of world
(define (ready-to-rally? w ke)
  (and (key=? ke " ") (world-ready-to-serve? w)))

;;; world-after-rally-start : World -> World
;;; GIVEN: a world
;;; RETURNS: the world in a start rally state in which
;;;          the ball's velocity components are (3,-9)
;;; DESIGN STRATEGY: Use constructor template for World
(define (world-after-rally-start w)
  (make-world
    RALLY-BALL
   (world-racket w)
   (world-speed w)
   RALLY
   -2))

;;; vx-decrease? : World KeyEvent -> Boolean
;;; GIVEN: a world and a key event
;;; RETURNS: true iff the Key pressed is left arrow and
;;;          the world is currently in a rally state
;;; DESIGN STRATEGY: Cases on keyevents and the state of world
(define (vx-decrease? w ke)
  (and (key=? ke "left") (world-rally? w)))

;;; world-after-vx-decrease : World -> World
;;; GIVEN: a world
;;; RETURNS: the world in a rally state decreases the vx
;;;          component of its racket by 1
;;; DESIGN STRATEGY: Use constructor template for World
(define (world-after-vx-decrease w)
  (make-world
   (world-balls w)
   (make-racket (- (racket-vx (world-racket w)) ONE)
                (racket-vy (world-racket w))
                (racket-x (world-racket w))
                (racket-y (world-racket w))
                FALSE -10 -10 -10 -10)
   (world-speed w)
   (world-state w)
   (world-tick-number w)))

;;; vx-increase? : World KeyEvent -> Boolean
;;; GIVEN: a world and a key event
;;; RETURNS: true iff the Key pressed is right arrow and
;;;          the world is currently in a rally state
;;; DESIGN STRATEGY: Cases on keyevents and the state of world
(define (vx-increase? w ke)
  (and (key=? ke "right") (world-rally? w)))

;;; world-after-vx-increase : World -> World
;;; GIVEN: a world
;;; RETURNS: the world in a rally state increases the vx
;;;          component of its racket by 1
;;; DESIGN STRATEGY: Use constructor template for World
(define (world-after-vx-increase w)
  (make-world
   (world-balls w)
   (make-racket (+ (racket-vx (world-racket w)) ONE)
                (racket-vy (world-racket w))
                (racket-x (world-racket w))
                (racket-y (world-racket w))
                FALSE -10 -10 -10 -10)
   (world-speed w)
   (world-state w)
   (world-tick-number w)))

;;; vy-decrease? : World KeyEvent -> Boolean
;;; GIVEN: a world and a key event
;;; RETURNS: true iff the Key pressed is up arrow and
;;;          the world is currently in a rally state
;;; DESIGN STRATEGY: Cases on keyevents and the state of world
(define (vy-decrease? w ke)
  (and (key=? ke "up") (world-rally? w)))

;;; world-after-vy-decrease : World -> World
;;; GIVEN: a world
;;; RETURNS: the world in a rally state decreases the vy
;;;          component of its racket by 1
;;; DESIGN STRATEGY: Use constructor template for World
(define (world-after-vy-decrease w)
  (make-world
   (world-balls w)
   (make-racket (racket-vx (world-racket w))
                (- (racket-vy (world-racket w)) ONE)
                (racket-x (world-racket w))
                (racket-y (world-racket w))
                FALSE -10 -10 -10 -10)
   (world-speed w)
   (world-state w)
   (world-tick-number w)))

;;; vy-increase? : World KeyEvent -> Boolean
;;; GIVEN: a world and a key event
;;; RETURNS: true iff the Key pressed is down arrow and
;;;          the world is currently in a rally state
;;; DESIGN STRATEGY: Cases on keyevents and the state of world
(define (vy-increase? w ke)
  (and (key=? ke "down") (world-rally? w)))

;;; world-after-vy-increase : World -> World
;;; GIVEN: a world
;;; RETURNS: the world in a rally state increases the vy
;;;          component of its racket by 1
;;; DESIGN STRATEGY: Use constructor template for World
(define (world-after-vy-increase w)
  (make-world
   (world-balls w)
   (make-racket (racket-vx (world-racket w))
                (+ (racket-vy (world-racket w)) ONE)
                (racket-x (world-racket w))
                (racket-y (world-racket w))
                FALSE -10 -10 -10 -10)
   (world-speed w)
   (world-state w)
   (world-tick-number w)))

;;; world-after-mouse-event : World Int Int MouseEvent -> World
;;; GIVEN: a world, the x and y coordinates of a mouse event,
;;;        and the mouse event
;;; RETURNS: the world that should follow the given world after
;;;       the given mouse event
(define (world-after-mouse-event w mx my mev)
  (if (world-rally? w)
      (make-world
       (world-balls w)
       (racket-after-mouse-event (world-racket w) mx my mev)
       (world-speed w)
       (world-state w)
       (world-tick-number w))
      w))

(begin-for-test
  (check-equal?
   (world-after-mouse-event NOT-PAUSED-WORLD-AT-1 135 380 "button-down")
   (make-world
    (list (make-ball 3 -9 100 300))
    (make-racket ZERO -8 150 400 TRUE 135 380 -15 -20) ONE RALLY
    NEG-ONE))
  
  (check-equal?
   (world-after-mouse-event NOT-PAUSED-WORLD-AT-1 135 380 "button-up")
   (make-world
    (list (make-ball 3 -9 100 300))
    (make-racket ZERO -8 150 400 FALSE -10 -10 -10 -10) ONE RALLY
    NEG-ONE))
  
  (check-equal?
   (world-after-mouse-event NOT-PAUSED-WORLD-AT-1 135 380 "drag")
   (make-world
    (list (make-ball 3 -9 100 300))
    (make-racket ZERO -8 150 400 TRUE 135 380 -10 -10) ONE RALLY
    NEG-ONE))
  
  (check-equal?
   (world-after-mouse-event NOT-PAUSED-WORLD-AT-1 135 380 "enter")
   (make-world
    (list (make-ball 3 -9 100 300))
    (make-racket ZERO -8 150 400 FALSE -10 -10 -10 -10) ONE RALLY
    NEG-ONE))
  
  (check-equal?
   (world-after-mouse-event READY-WORLD-AT-1 135 380 "button-down")
   (make-world
    (list (make-ball 0 0 330 384))
    (make-racket 0 0 330 384 FALSE -10 -10 -10 -10) ONE READY
    NEG-ONE)))

;;; racket-after-mouse-event : Racket Int Int MouseEvent -> Racket
;;; GIVEN: a racket, the x and y coordinates of a mouse event,
;;;        and the mouse event
;;; RETURNS: the racket as it should be after the given mouse event
;;; DESIGN STRATEGY: Divide into cases on mouse events
(define (racket-after-mouse-event r mx my mev)
  (cond
    [(mouse=? mev "button-up") (racket-after-button-up r)]
    [(mouse=? mev "button-down") (racket-after-button-down r mx my)]
    [(mouse=? mev "drag") (racket-after-drag r mx my)]
    [else r]))
(begin-for-test
  (check-equal?
   (racket-after-mouse-event RACKET-FOR-MOUSE-TEST 135 380
                             "button-up")
   (make-racket 0 -8 150 400 FALSE -10 -10 -10 -10))
  (check-equal?
   (racket-after-mouse-event RACKET-FOR-MOUSE-TEST 135 380 "drag")
   (make-racket 0 -8 120 360 TRUE 135 380 15 20))
  (check-equal?
   (racket-after-mouse-event RACKET-FOR-MOUSE-TEST 135 380
                             "button-down")
   (make-racket 0 -8 150 400 TRUE 135 380 -15 -20))
  (check-equal?
   (racket-after-mouse-event RACKET-FOR-SELECT-TEST 135 380
                             "button-down")
   (make-racket 0 -8 40 400 FALSE 135 380 95 -20)))
;;; RACKET-FOR-TEST
(define RACKET-FOR-MOUSE-TEST
  (make-racket ZERO -8 150 400 TRUE 135 380 15 20))
(define RACKET-FOR-SELECT-TEST
  (make-racket ZERO -8 40 400 TRUE 135 380 15 20))

;;; racket-after-button-up : Racket Int Int -> Racket
;;; GIVEN: a racket, the x and y coordinates of a mouse event
;;; RETURNS: the racket after button up
;;; DESIGN STRATEGY: Use constructor template for Racket
(define (racket-after-button-up r)
      (make-racket (racket-vx r) (racket-vy r) (racket-x r)
                  (racket-y r) FALSE -10 -10 -10 -10))

;;; racket-after-button-down : Racket Int Int -> Racket
;;; GIVEN: a racket, the x and y coordinates of a mouse event
;;; RETURNS: the racket with its selected? change to TRUE if
;;;          the mouse is around the racket(around-racket? r mx my)
;;; DESIGN STRATEGY: Use constructor template for Racket
(define (racket-after-button-down r mx my)
  (if (around-racket? r mx my)
      (make-racket (racket-vx r) (racket-vy r)
                  (racket-x r)
                  (racket-y r)
                  TRUE mx my
                  (- mx (racket-x r))
                  (- my (racket-y r)))
      (make-racket (racket-vx r) (racket-vy r)
                  (racket-x r)
                  (racket-y r)
                  FALSE mx my
                  (- mx (racket-x r))
                  (- my (racket-y r)))))

;;; racket-after-drag : Racket Int Int -> Racket
;;; GIVEN: a racket, the x and y coordinates of a mouse event
;;; RETURNS: the racket after drag
;;; DESIGN STRATEGY: Use constructor template for Racket
(define (racket-after-drag r mx my)
  (if (racket-selected? r)
      (make-racket (racket-vx r) (racket-vy r)
                  (- mx (racket-d-x r))
                  (- my (racket-d-y r)) TRUE
                  mx my (racket-d-x r) (racket-d-y r))
      (make-racket (racket-vx r) (racket-vy r)
                  (racket-x r)
                  (racket-y r) TRUE
                  mx my -10 -10)))


;;; racket-selected? : Racket-> Boolean
;;; GIVEN: a racket
;;; RETURNS: true iff the racket is selected

;;; around-racket? : Racket Integer Integer -> World
;;; RETURNS: true iff the given coordinate is s positioned no more than 25 pixels
;;;          away from the center of the racket 
;;; EXAMPLES: see tests below
;;; DESIGN STRATEGY: Use observer template on World w
(define (around-racket? r mx my)
  (<=
   (+ (* (- mx (racket-x r)) (- mx (racket-x r)))
      (* (- my (racket-y r)) (- my (racket-y r))))
   625))

(begin-for-test
  (check-equal?
   (around-racket? RACKET-FOR-AROUND-TEST 20 20) FALSE)
  (check-equal?
   (around-racket? RACKET-FOR-AROUND-TEST 135 380) TRUE))
(define RACKET-FOR-AROUND-TEST
  (make-racket ZERO -8 150 400 FALSE 135 380 15 20))

          
;;; world-ball : World -> Ball
;;; GIVEN: a world
;;; RETURNS: the ball that's present in the world
          
;;; world-racket : World -> Racket
;;; GIVEN: a world
;;; RETURNS: the racket that's present in the world
          
;;; ball-x : Ball -> Integer
;;; ball-y : Ball -> Integer
;;; racket-x : Racket -> Integer
;;; racket-y : Racket -> Integer
;;; GIVEN: a racket or ball
;;; RETURNS: the x or y coordinate of that item's position,
;;;     in graphics coordinates
          
;;; ball-vx : Ball -> Integer
;;; ball-vy : Ball -> Integer
;;; racket-vx : Racket -> Integer
;;; racket-vy : Racket -> Integer
;;; GIVEN: a racket or ball
;;; RETURNS: the vx or vy component of that item's velocity,
;;;     in pixels per tick

