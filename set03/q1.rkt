;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(require 2htdp/universe)
(require 2htdp/image)
(check-location "03" "q1.rkt")

(provide
 simulation
 initial-world
 world-ready-to-serve?
 world-after-tick
 world-after-key-event
 world-ball
 world-racket
 ball-x
 ball-y
 racket-x
 racket-y
 ball-vx
 ball-vy
 racket-vx
 racket-vy)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;; Court
(define WHITE-COURT (empty-scene COURT-WIDTH COURT-HEIGHT "white"))
(define YELLOW-COURT (empty-scene COURT-WIDTH COURT-HEIGHT "yellow"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; DATA DEFINITIONS

;; REPRESENTATION:
;; A Ball is represented as a (make-ball vx vy x y)
;; INTERPRETATION:
;; vx : Integer is how many pixels the ball moves on each tick in
;;      the x directions
;; vy : Integer is how many pixels the ball moves on each tick in 
;;      the y directions
;; x, y: Real the position of the center of the ball in 
;;               the scene 

;; IMPLEMENTATION:
(define-struct ball (vx vy x y))

;; CONSTRUCTOR TEMPLATE:
;; (make-ball Integer Integer Real Real)

;; OBSERVER TEMPLATE:
;; ball-fn : Ball -> ??
(define (ball-fn b)
  (...
   (ball-vx b)
   (ball-vy b)
   (ball-x b)
   (ball-y b)))

;;; Examples of balls, for testing
(define READY-BALL (make-ball READY-VX READY-VY READY-X READY-Y))

;; REPRESENTATION:
;; A Racket is represented as a (make-racket vx vy x y)
;; INTERPRETATION:
;; vx : Integer is how many pixels the racket moves on each tick in
;;      the x directions
;; vy : Integer is how many pixels the racket moves on each tick in 
;;      the y directions
;; x, y: Real the position of the center of the racket in 
;;               the scene 

;; IMPLEMENTATION:
(define-struct racket (vx vy x y))

;; CONSTRUCTOR TEMPLATE:
;; (make-racket Integer Integer Real Real)

;; OBSERVER TEMPLATE:
;; racket-fn : Racket -> ??
(define (racket-fn r)
  (...
   (racket-vx r)
   (racket-vy r)
   (racket-x r)
   (racket-y r)))

;;; Examples of rackets, for testing
(define READY-RACKET (make-racket READY-VX READY-VY READY-X READY-Y))

;; REPRESENTATION
;; A World is represented as a
;;(make-world ball racket paused? speed ready-to-serve? rally? court)
;; INTEPRETATION：
;; ball    : Ball     the ball in the world
;; racket  : Racket   the racket in the world
;; speed   : Real     is the speed of the simulation of the world,
;;                    in seconds per tick
;; ready-to-serve? : Boolean is the world in a ready-to-serve
;;                           state?
;; rally?  : Boolean  is the world in a rally state?
;; court : COURT the type of court of the world
;; tick-number : Nonnegative-Integer the number of ticks of the world

;; IMPLEMENTATION:
(define-struct world (ball racket speed ready-to-serve? rally? court
                           tick-number))

;; CONSTRUCTOR TEMPLATE:
;; (make-world Ball Racket Real Boolean Boolean Court
;;                                      Nonnegative-Integer)

;; OBSERVER TEMPLATE:
;; world-fn : World -> ??
(define (world-fn w)
  (...
   (world-ball w)
   (world-racket w)
   (world-speed w)
   (world-ready-to-serve? w)
   (world-rally? w)
   (world-court w)
   (world-tick-number w)))

;; Examples of worlds, for testing
;; world at the ready-to-serve state
(define READY-WORLD-AT-1
  (make-world (make-ball READY-VX READY-VY READY-X READY-Y)
              (make-racket READY-VX READY-VY READY-X READY-Y)
              ONE TRUE FALSE WHITE-COURT NEG-ONE))
(define WORLD-AFTER-RALLY-START-AT-1
  (make-world (make-ball 3 -9 READY-X READY-Y)
  (make-racket READY-VX READY-VY READY-X READY-Y)
  ONE FALSE TRUE WHITE-COURT NEG-ONE))

;; the world with its ball colliding with the bottom wall at the next
;; tick
(define BALL-BOTTOM-WORLD-AT-1
  (make-world (make-ball 3 9 220 645)
              (make-racket READY-VX READY-VY READY-X READY-Y)
              ONE FALSE TRUE WHITE-COURT NEG-ONE))

;; the world with its racket colliding with the front wall at the
;; next tick
(define RACKET-FRONT-WORLD-AT-1
  (make-world (make-ball 3 -9 100 100)
              (make-racket 0 -8 220 5)
              ONE FALSE TRUE WHITE-COURT NEG-ONE))

;; the world paused for ball colliding with the bottom wall
(define BALL-PAUSED-WORLD-AT-1
  (make-world (make-ball ZERO ZERO 220 645)
              (make-racket ZERO ZERO READY-X READY-Y)
              ONE FALSE FALSE YELLOW-COURT ZERO))

;; the world paused for racket colliding with the front wall
(define RACKET-PAUSED-WORLD-AT-1
  (make-world (make-ball ZERO ZERO 100 100)
              (make-racket ZERO ZERO 220 5)
              ONE FALSE FALSE YELLOW-COURT ZERO))

;; the world not being paused
(define NOT-PAUSED-WORLD-AT-1
  (make-world (make-ball 3 -9 100 300)
              (make-racket ZERO -8 150 400)
              ONE FALSE TRUE WHITE-COURT NEG-ONE))

;; the world not being paused after one tick
(define TICK-LATER-WORLD-AT-1
  (make-world (make-ball 3 -9 103 291)
              (make-racket ZERO -8 150 392)
              ONE FALSE TRUE WHITE-COURT NEG-ONE))

;; the world paused without ball and racket colliding
(define PAUSED-WORLD-AT-1
  (make-world (make-ball ZERO ZERO 100 100)
              (make-racket ZERO ZERO 220 220)
              ONE FALSE FALSE YELLOW-COURT ZERO))

;; the world one tick later after pausing (still in paused staet)
;; without ball and racket colliding
(define TICK-LATER-PAUSED-WORLD-AT-1
  (make-world (make-ball ZERO ZERO 100 100)
              (make-racket ZERO ZERO 220 220)
              ONE FALSE FALSE YELLOW-COURT ONE))

;; the world at the end of its paused state
(define END-PAUSED-WORLD-AT-1
    (make-world (make-ball ZERO ZERO 100 100)
              (make-racket ZERO ZERO 220 220)
              ONE FALSE FALSE YELLOW-COURT (/ THREE ONE)))

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
            (on-key world-after-key-event)))

;;; initial-world : PosReal -> World
;;; GIVEN: the speed of the simulation, in seconds per tick
;;;     (so larger numbers run slower)
;;; RETURNS: the ready-to-serve state of the world
;;; EXAMPLE: (initial-world 1) = READY-WORLD-AT-1
;;; DESIGN STRATEGY: Use constrcutor template for World
(define (initial-world s)
  (make-world
    (make-ball READY-VX READY-VY READY-X READY-Y)
    (make-racket READY-VX READY-VY READY-X READY-Y)
    s
    TRUE
    FALSE
    WHITE-COURT
    NEG-ONE))
(begin-for-test
  (check-equal?
   (initial-world 1)
   READY-WORLD-AT-1))
           
;;; world-to-scene : World -> Scene
;;; GIVEN:   a world
;;; RETURNS: a Scene that portrays the given world.
;;; EXAMPLE: (world-to-scene READY-WORLD-AT-1) should return a white
;;;           canvas with the ball and racket both at (330,384)
;;; DESIGN STRATEGY: Place ball and racket in turn.
(define (world-to-scene w)
  (scene-with-ball
    (world-ball w)
    (scene-with-racket
      (world-racket w)
      (world-court w))))
(define IMAGE-OF-READY-WORLD-AT-1
  (place-image BALL-SHAPE READY-X READY-Y
    (place-image RACKET-SHAPE READY-X READY-Y
      WHITE-COURT)))
(begin-for-test
  (check-equal?
   (world-to-scene READY-WORLD-AT-1)
   IMAGE-OF-READY-WORLD-AT-1))

;;  scene-with-ball : Ball Scene -> Scene
;;; RETURNS: a scene like the given one, but with the given ball
;;;          painted on it
;;; Example: (scene-with-ball READY-BALL WHITE-COURT) should return a
;;;          white canvas with the ball at (330, 384)
;;; DESIGN STRATEGY: Place the image of the cat on an empty canvas 
;;                   at the right position
(define (scene-with-ball b s)
  (place-image
    BALL-SHAPE
    (ball-x b) (ball-y b)
    s))
(define BALL-IMAGE-AT-READY-WORLD
  (place-image BALL-SHAPE READY-X READY-Y WHITE-COURT))
(begin-for-test
  (check-equal?
   (scene-with-ball READY-BALL WHITE-COURT)
   BALL-IMAGE-AT-READY-WORLD))

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
   RACKET-IMAGE-AT-READY-WORLD))
          
;;; world-ready-to-serve? : World -> Boolean
;;; GIVEN: a world
;;; RETURNS: true iff the world is in its ready-to-serve state

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
        [(ball-collides-bottom-wall? (world-racket w) (world-ball w)
                                     (world-rally? w))
         (world-after-pause w)]
        [(racket-collide-front-wall? (world-racket w))
         (world-after-pause w)]
        [(= (world-tick-number w) NEG-ONE)
         (make-world
           (ball-after-tick
           (world-racket w) (world-ball w) (world-rally? w))
           (racket-after-tick (world-racket w) (world-ball w)
                              (world-rally? w))
           (world-speed w)
           (world-ready-to-serve? w)
           (world-rally? w)
           (world-court w)
           (world-tick-number w))]
        [(< (world-tick-number w) (/ THREE (world-speed w)))
         (world-after-pause w)]
        [(= (world-tick-number w) (/ THREE (world-speed w)))
         (initial-world (world-speed w))]))
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Functions for Ball

;;; ball-after-tick:Racket Ball World-rally? World-tick-number-> Ball
;;; GIVEN: the state of a ball b and a racket r in a rally-state world
;;;        and world-rally? w-r of the world and the world itself
;;; RETURNS: the state of the given ball after a tick.
;;; EXAMPLES:
;;; ball collides with both front wall and right wall:
;;;      (ball-after-tick RACKET-NOT-COLLIDE-BALL
;;;                       BALL-COLLIDE-FRONT-RIGHT TRUE)
;;;                           =BALL-AFTER-COLLIDE-FRONT-RIGHT
;;; DESIGN STRATEGY: Divide into cases on the conditions of ball's
;;;                  collision with walls and racket
(define (ball-after-tick r b w-r)
  (cond
    [(and (ball-collides-front-wall? r b w-r)
          (ball-collides-right-wall? r b w-r))
     (ball-front-right-wall b)]
    [(and (ball-collides-front-wall? r b w-r)
          (ball-collides-left-wall? r b w-r))
     (ball-front-left-wall b)]
    [(ball-collides-front-wall? r b w-r)
     (ball-after-collide-front b)]
    [(ball-collides-left-wall? r b w-r)
     (ball-after-collide-left b)]
    [(ball-collides-right-wall? r b w-r)
     (ball-after-collide-right b)]
    [(ball-collides-with-racket? r b w-r)
     (ball-after-collide-racket b r)]
    [else (ball-not-collide b)]))
;;; TESTS
;;; Examples of balls and racket, for testing
(define RACKET-FOR-TEST (make-racket 0 5 100 100))

(define BALL-NO-COLLIDE (make-ball 3 -9 200 200))
(define BALL-COLLIDE-RACKET (make-ball 3 -9 90 110))
(define BALL-COLLIDE-FRONT (make-ball 3 -9 220 5))
(define BALL-COLLIDE-LEFT (make-ball -3 9 2 220))
(define BALL-COLLIDE-RIGHT (make-ball 3 9 423 220))
(define BALL-COLLIDE-BOTTOM (make-ball 3 9 200 645))
(define BALL-COLLIDE-FRONT-RIGHT (make-ball 3 -9 423 5))
(define BALL-COLLIDE-FRONT-LEFT (make-ball -3 -9 2 5))

(define BALL-AFTER-NO-COLLIDE (make-ball 3 -9 203 191))
(define BALL-AFTER-COLLIDE-WITH-RACKET (make-ball 3 9 93 119))
(define BALL-AFTER-COLLIDE-RIGHT-WALL (make-ball -3 9 424 229))
(define BALL-AFTER-COLLIDE-LEFT-WALL (make-ball 3 9 1 229))
(define BALL-AFTER-COLLIDE-FRONT-RIGHT (make-ball -3 9 424 4))
(define BALL-AFTER-COLLIDE-FRONT-LEFT (make-ball 3 9 1 4))
(define BALL-AFTER-COLLIDE-FRONT-WALL (make-ball 3 9 223 4))
(begin-for-test
  (check-equal?
   (ball-after-tick RACKET-FOR-TEST BALL-COLLIDE-FRONT-RIGHT
                    TRUE)
   BALL-AFTER-COLLIDE-FRONT-RIGHT)
  (check-equal?
   (ball-after-tick RACKET-FOR-TEST BALL-COLLIDE-FRONT-LEFT
                    TRUE)
   BALL-AFTER-COLLIDE-FRONT-LEFT)
  (check-equal?
   (ball-after-tick RACKET-FOR-TEST BALL-COLLIDE-FRONT
                    TRUE)
   BALL-AFTER-COLLIDE-FRONT-WALL)
  (check-equal?
   (ball-after-tick RACKET-FOR-TEST BALL-COLLIDE-LEFT
                    TRUE)
   BALL-AFTER-COLLIDE-LEFT-WALL)
  (check-equal?
   (ball-after-tick RACKET-FOR-TEST BALL-COLLIDE-RIGHT
                    TRUE)
   BALL-AFTER-COLLIDE-RIGHT-WALL)
  (check-equal?
   (ball-after-tick RACKET-FOR-TEST BALL-COLLIDE-RACKET
                    TRUE)
   BALL-AFTER-COLLIDE-WITH-RACKET)
  (check-equal?
   (ball-after-tick RACKET-FOR-TEST BALL-NO-COLLIDE
                    TRUE)
   BALL-AFTER-NO-COLLIDE))

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
   (ball-front-left-wall BALL-COLLIDE-FRONT-LEFT)
    BALL-AFTER-COLLIDE-FRONT-LEFT))

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
   (ball-front-right-wall BALL-COLLIDE-FRONT-RIGHT)
    BALL-AFTER-COLLIDE-FRONT-RIGHT))

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
   (ball-not-collide BALL-NO-COLLIDE) BALL-AFTER-NO-COLLIDE))

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
   (ball-after-collide-front BALL-COLLIDE-FRONT)
                                    BALL-AFTER-COLLIDE-FRONT-WALL))

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
   (ball-after-collide-left BALL-COLLIDE-LEFT)
                                    BALL-AFTER-COLLIDE-LEFT-WALL))

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
   (ball-after-collide-right BALL-COLLIDE-RIGHT)
                                    BALL-AFTER-COLLIDE-RIGHT-WALL))

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
   (- ZERO (ball-vy b))
   (+ (ball-x b) (ball-vx b))
   (+ (ball-y b) (- ZERO (ball-vy b)))))
(begin-for-test
  (check-equal?
   (ball-after-collide-racket BALL-COLLIDE-RACKET RACKET-FOR-TEST)
                                    BALL-AFTER-COLLIDE-WITH-RACKET))

;;; path-x-at-racket-vy : Racket-vy Ball -> Real
;;; GIVEN: the vy coordinate of a racket after a tick and a ball b
;;;        in a rally-state world
;;; RETURNS: the x coordinate when the y coordinate of ball path
;;;          between two ticks is same as racket-vy
;;; EXAMPLE: (path-x-at-racket-vy 105 (make-ball 3 -9 90 110))
;;;                          = (/ 275 3)
;;; DESIGN STRATEGY: Transcribe formula
(define (path-x-at-racket-vy ry b)
  (+ (ball-x b)
     (/ (* (- ry (ball-y b))
           (ball-vx b))
        (ball-vy b))))
(begin-for-test
  (check-equal? (path-x-at-racket-vy 105 (make-ball 3 -9 90 110))
   (/ 275 3)))

;;; ball-collides-with-racket? : Racket Ball World-rally? -> Boolean
;;; GIVEN: the state of a racket r and a ball b in a
;;;        rally-state world and world-rally? of the world
;;; RETURNS: true if the ball collides with the racket
;;; EXAMPLE: (ball-collides-with-racket? RACKET-FOR-TEST
;;;           BALL-COLLIDE-RACKET TRUE) = TRUE
;;;          (ball-collides-with-racket? RACKET-FOR-TEST
;;;           BALL-COLLIDE-RIGHT TRUE) = FALSE
;;; DESIGN STRATEGY: Use math principle for two line's intersection
(define (ball-collides-with-racket? r b w-r)
   (and w-r
        (> (path-x-at-racket-vy (+ (racket-y r) (racket-vy r)) b)
          (- (racket-x r) (/ RACKET-HSIDE TWO)))
        (< (path-x-at-racket-vy (+ (racket-y r) (racket-vy r)) b)
          (+ (racket-x r) (/ RACKET-HSIDE TWO)))
        (> (path-x-at-racket-vy (+ (racket-y r) (racket-vy r)) b)
                (min (ball-x b) (+ (ball-x b) (ball-vx b))))
        (< (path-x-at-racket-vy (+ (racket-y r) (racket-vy r)) b)
                (max (ball-x b) (+ (ball-x b) (ball-vx b))))))
(begin-for-test
  (check-equal? (ball-collides-with-racket? RACKET-FOR-TEST
                 BALL-COLLIDE-RACKET TRUE) TRUE)
  (check-equal? (ball-collides-with-racket? RACKET-FOR-TEST
                 BALL-COLLIDE-RIGHT TRUE) FALSE))

;;; ball-collides-front-wall? : Ball Racket World-rally? -> Boolean
;;; GIVEN: the state of a racket r and a ball b in a
;;;        rally-state world and world-rally? of the world
;;; RETURNS: true if the ball's tentative new position lies outside  
;;;          the front wall of the court and does not collides with 
;;;          the racket
;;; EXAMPLE: (ball-collides-front-wall? RACKET-FOR-TEST
;;;                                 BALL-COLLIDE-FRONT TRUE) = TRUE
;;;          (ball-collides-front-wall? RACKET-FOR-TEST
;;;                                 BALL-COLLIDE-RIGHT TRUE) = FALSE
;;; DESIGN STRATEGY: Compare ball's tentative y component with 0
(define (ball-collides-front-wall? r b w-r)
  (and (not (ball-collides-with-racket? r b w-r))
       (< (+ (ball-y b) (ball-vy b)) ZERO)))
(begin-for-test
  (check-equal? (ball-collides-front-wall? RACKET-FOR-TEST
                                 BALL-COLLIDE-FRONT TRUE) TRUE)
  (check-equal? (ball-collides-front-wall? RACKET-FOR-TEST
                                 BALL-COLLIDE-RIGHT TRUE) FALSE))

;;; ball-collides-bottom-wall? : Ball Racket World-rally?-> Boolean
;;; GIVEN: the state of a racket r and a ball b in a
;;;        rally-state world and world-rally? of the world
;;; RETURNS: true if the ball's tentative new position lies outside  
;;;          the bottom wall of the court and does not collides 
;;;          with  the racket
;;; EXAMPLE: (ball-collides-bottom-wall? RACKET-FOR-TEST
;;;                                 BALL-COLLIDE-BOTTOM TRUE)=FALSE
;;;          (ball-collides-bottom-wall? RACKET-FOR-TEST
;;;                                 BALL-COLLIDE-RIGHT TRUE)=FALSE
;;; DESIGN STRATEGY: Compare ball's tentative y component with
;;;                  COURT-HEIGHT
(define (ball-collides-bottom-wall? r b w-r)
  (and (not (ball-collides-with-racket? r b w-r))
       (> (+ (ball-y b) (ball-vy b)) COURT-HEIGHT)))
(begin-for-test
  (check-equal? (ball-collides-bottom-wall? RACKET-FOR-TEST
                                 BALL-COLLIDE-BOTTOM TRUE) TRUE)
  (check-equal? (ball-collides-bottom-wall? RACKET-FOR-TEST
                                 BALL-COLLIDE-RIGHT TRUE) FALSE))

;;; ball-collides-left-wall? : Ball Racket World-rally?-> Boolean
;;; GIVEN: the state of a racket r and a ball b in a
;;;        rally-state world and world-rally? of the world
;;; RETURNS: true if the ball's tentative new position lies outside  
;;;          the left wall of the court and does not collides with 
;;;          the racket
;;; EXAMPLE: (ball-collides-left-wall? RACKET-FOR-TEST
;;;                                 BALL-COLLIDE-LEFT TRUE) = FALSE
;;;          (ball-collides-left-wall? RACKET-FOR-TEST
;;;                                 BALL-COLLIDE-RIGHT TRUE) = FALSE
;;; DESIGN STRATEGY：Compare ball's tentative x component with 0
(define (ball-collides-left-wall? r b w-r)
  (and (not (ball-collides-with-racket? r b w-r))
       (< (+ (ball-x b) (ball-vx b)) ZERO)))

;;; ball-collides-right-wall? : Ball Racket World-rally?-> Boolean
;;; GIVEN: the state of a racket r and a ball b in a
;;;        rally-state world and world-rally? of the world
;;; RETURNS: true if the ball's tentative new position lies outside  
;;;          the right wall of the court and does not collides with 
;;;          the racket
;;; EXAMPLE: (ball-collides-right-wall? RACKET-FOR-TEST
;;;                                 BALL-COLLIDE-RIGHT TRUE) = TRUE
;;;          (ball-collides-right-wall? RACKET-FOR-TEST
;;;                                 BALL-COLLIDE-LEFT TRUE) = FALSE
;;; DESIGN STRATEGY: Compare ball's tentative x component with
;;;                  COURT-WIDTH
(define (ball-collides-right-wall? r b w-r)
  (and (not (ball-collides-with-racket? r b w-r))
       (> (+ (ball-x b) (ball-vx b)) COURT-WIDTH)))
(begin-for-test
  (check-equal? (ball-collides-right-wall? RACKET-FOR-TEST
                                 BALL-COLLIDE-RIGHT TRUE) TRUE)
  (check-equal? (ball-collides-right-wall? RACKET-FOR-TEST
                                 BALL-COLLIDE-LEFT TRUE) FALSE))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Functions for Racket

;;; racket-after-tick : Racket Ball World-rally? -> Racket
;;; GIVEN: a world w and its racket r
;;; RETURNS: the state of the given racket after a tick.
;;; EXAMPLES: as the tests below
;;; DESIGN STRATEGY: Divide into cases on racket's collision with
;;;                  ball and walls
(define (racket-after-tick r b w-r)
   (cond
     [(and
       (ball-collides-with-racket? r b w-r)
       (< (racket-vy r) ZERO))
      (racket-after-collide-ball r)]
     [(and (racket-collide-left-wall? r)
           (racket-collide-bottom-wall? r))
      (racket-collide-left-bottom r)]
     [(and (racket-collide-right-wall? r)
           (racket-collide-bottom-wall? r))
      (racket-collide-right-bottom r)]
     [(racket-collide-left-wall? r) (racket-after-collide-left r)]
     [(racket-collide-right-wall? r) (racket-after-collide-right r)]
     [(racket-collide-bottom-wall? r) (racket-after-collide-bottom r)]
     [else (racket-not-collide r)]))

;;; TESTS
;;; Examples of rackets and ball, for testing
(define BALL-FOR-TEST (make-ball -3 9 102 89))

(define RACKET-NO-COLLIDE (make-racket 0 5 200 200))
(define RACKET-COLLIDE-BALL (make-racket 0 -5 100 100))
(define RACKET-COLLIDE-LEFT (make-racket -5 0 2 100))
(define RACKET-COLLIDE-RIGHT (make-racket 5 0 423 100))
(define RACKET-COLLIDE-FRONT (make-racket 0 -5 100 2))
(define RACKET-COLLIDE-BOTTOM (make-racket 0 5 100 646))
(define RACKET-COLLIDE-LEFT-BOTTOM (make-racket -5 5 2 646))
(define RACKET-COLLIDE-RIGHT-BOTTOM (make-racket 5 5 423 646))

(define RACKET-AFTER-NO-COLLIDE (make-racket 0 5 200 205))
(define RACKET-AFTER-COLLIDE-WITH-BALL (make-racket 0 0 100 100))
(define RACKET-AFTER-COLLIDE-WITH-LEFT (make-racket -5 0 23.5 100))
(define RACKET-AFTER-COLLIDE-WITH-RIGHT (make-racket 5 0 401.5 100))
(define RACKET-AFTER-COLLIDE-WITH-BOTTOM (make-racket 0 0 100 649))
(define RACKET-AFTER-COLLIDE-LEFT-BOTTOM (make-racket -5 5 23.5 649))
(define RACKET-AFTER-COLLIDE-RIGHT-BOTTOM (make-racket 5 5 401.5 649))

(begin-for-test
  (check-equal?
   (racket-after-tick RACKET-COLLIDE-BALL BALL-FOR-TEST true)
    RACKET-AFTER-COLLIDE-WITH-BALL)
  (check-equal?
   (racket-after-tick RACKET-COLLIDE-LEFT-BOTTOM BALL-FOR-TEST true)
    RACKET-AFTER-COLLIDE-LEFT-BOTTOM)
  (check-equal?
   (racket-after-tick RACKET-COLLIDE-RIGHT-BOTTOM BALL-FOR-TEST true)
    RACKET-AFTER-COLLIDE-RIGHT-BOTTOM)
  (check-equal?
   (racket-after-tick RACKET-COLLIDE-LEFT BALL-FOR-TEST true)
    RACKET-AFTER-COLLIDE-WITH-LEFT)
  (check-equal?
   (racket-after-tick RACKET-COLLIDE-RIGHT BALL-FOR-TEST true)
    RACKET-AFTER-COLLIDE-WITH-RIGHT)
  (check-equal?
   (racket-after-tick RACKET-COLLIDE-BOTTOM BALL-FOR-TEST true)
    RACKET-AFTER-COLLIDE-WITH-BOTTOM)
  (check-equal?
   (racket-after-tick RACKET-NO-COLLIDE BALL-FOR-TEST true)
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
   (/ RACKET-HSIDE TWO)
   COURT-HEIGHT))
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
   (- COURT-WIDTH (/ RACKET-HSIDE TWO))
   COURT-HEIGHT))
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
  (make-racket
        (racket-vx r)
        (racket-vy r)
        (+ (racket-x r) (racket-vx r))
        (+ (racket-y r) (racket-vy r))))
(begin-for-test
  (check-equal?
   (racket-not-collide RACKET-NO-COLLIDE)
   RACKET-AFTER-NO-COLLIDE))

;;; racket-after-collide-ball : Racket -> Racket
;;; GIVEN: a Racket r
;;; RETURNS: the racket with its vy component being zero
;;; DESIGN STRATEGY: Use constructor template for Racket
(define (racket-after-collide-ball r)
  (make-racket
        (racket-vx r)
        ZERO
        (+ (racket-x r) (racket-vx r))
        (racket-y r)))
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
   (/ RACKET-HSIDE TWO)
   (+ (racket-y r) (racket-vy r))))
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
   (- COURT-WIDTH (/ RACKET-HSIDE TWO))
   (+ (racket-y r) (racket-vy r))))
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
   COURT-HEIGHT))
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
    [else w]))
;;; TESTS
;;; Exampels of world, for testing
(define RALLY-WORLD-AT-1
  (make-world (make-ball 3 -9 100 100)
              (make-racket 0 3 220 220)
              ONE FALSE TRUE WHITE-COURT NEG-ONE))
(define RACKET-VX-DECREASE-WORLD-AT-1
  (make-world (make-ball 3 -9 100 100)
              (make-racket -1 3 220 220)
              ONE FALSE TRUE WHITE-COURT NEG-ONE))
(define RACKET-VX-INCREASE-WORLD-AT-1
  (make-world (make-ball 3 -9 100 100)
              (make-racket 1 3 220 220)
              ONE FALSE TRUE WHITE-COURT NEG-ONE))
(define RACKET-VY-DECREASE-WORLD-AT-1
  (make-world (make-ball 3 -9 100 100)
              (make-racket 0 2 220 220)
              ONE FALSE TRUE WHITE-COURT NEG-ONE))
(define RACKET-VY-INCREASE-WORLD-AT-1
  (make-world (make-ball 3 -9 100 100)
              (make-racket 0 4 220 220)
              ONE FALSE TRUE WHITE-COURT NEG-ONE))
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
   (world-after-key-event READY-WORLD-AT-1 "r")
    (make-world
     (make-ball 0 0 330 384)
     (make-racket 0 0 330 384)
     ONE TRUE FALSE WHITE-COURT NEG-ONE)))

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
  (make-ball
    ZERO ZERO (ball-x (world-ball w)) (ball-y (world-ball w)))
  (make-racket
    ZERO ZERO (racket-x (world-racket w)) (racket-y (world-racket w)))
  (world-speed w)
  FALSE
  FALSE
  YELLOW-COURT
  (+ (world-tick-number w) ONE)))

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
   (make-ball
    3 -9 (ball-x (world-ball w)) (ball-y (world-ball w)))
   (world-racket w)
   (world-speed w)
   (not (world-ready-to-serve? w))
   (not (world-rally? w))
   (world-court w)
   (world-tick-number w)))

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
   (world-ball w)
   (make-racket (- (racket-vx (world-racket w)) ONE)
                (racket-vy (world-racket w))
                (racket-x (world-racket w))
                (racket-y (world-racket w)))
   (world-speed w)
   (world-ready-to-serve? w)
   (world-rally? w)
   (world-court w)
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
   (world-ball w)
   (make-racket (+ (racket-vx (world-racket w)) ONE)
                (racket-vy (world-racket w))
                (racket-x (world-racket w))
                (racket-y (world-racket w)))
   (world-speed w)
   (world-ready-to-serve? w)
   (world-rally? w)
   (world-court w)
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
   (world-ball w)
   (make-racket (racket-vx (world-racket w))
                (- (racket-vy (world-racket w)) ONE)
                (racket-x (world-racket w))
                (racket-y (world-racket w)))
   (world-speed w)
   (world-ready-to-serve? w)
   (world-rally? w)
   (world-court w)
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
   (world-ball w)
   (make-racket (racket-vx (world-racket w))
                (+ (racket-vy (world-racket w)) ONE)
                (racket-x (world-racket w))
                (racket-y (world-racket w)))
   (world-speed w)
   (world-ready-to-serve? w)
   (world-rally? w)
   (world-court w)
   (world-tick-number w)))

;;; rally-to-pause? : World KeyEvent -> Boolean
;;; GIVEN: a world and a key event
;;; RETURNS: true iff the Key pressed is space bar and
;;;          the world is currently in a rally state

;;; world-after-rally-pause : World -> World
;;; GIVEN: a world
;;; RETURNS: the world just liken the given world but paused
;;;          for 3 seconds, then the world changes to
;;;          ready-to-serve state

          
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