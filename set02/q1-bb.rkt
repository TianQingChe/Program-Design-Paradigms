#lang racket

(require rackunit)
(require rackunit/text-ui)
(require "q1.rkt")

(define tests
  (test-suite
   "q1"  
   
   (test-case
    "Test #1"
    (check-equal? (lexer-token (make-lexer "ac" "b")) "ac"
                  "returns the correct token for the given lexer"))
   
   (test-case
    "Test #2"
    (check-equal? (lexer-input (make-lexer "ac" "bde")) "bde"
                  "returns the correct input string for the given lexer"))
   
   (test-case
    "Test #3"
    (check-equal? (initial-lexer "abc")  (make-lexer "" "abc")
                  "returns the lexer with no token and the given input"))
   
   (test-case
    "Test #4"
    (check-equal? (lexer-stuck? (make-lexer "abc" "#1234")) true
                  "returns true as the input string starts with a special character"))
   
   (test-case
    "Test #5"
    (check-equal? (lexer-stuck? (make-lexer "abc" "1234")) false
                  "returns false as the given lexer has input string which starts with a digit"))
   
   (test-case
    "Test #6"
    (check-equal? (lexer-stuck? (make-lexer "abcdef" "")) true
                  "returns true as the input string of the lexer is empty"))
   
   (test-case
    "Test #7"
    (check-equal? (lexer-shift (make-lexer "abc" "")) (make-lexer "abc" "")
                  "returns the given lexer as the input string is empty as the lexer is stuck"))
   
   (test-case
    "Test #8"
    (check-equal? (lexer-shift (make-lexer "abc" "xyz")) (make-lexer "abcx" "yz")
                  "returns a lexer with a single character of input string shifted to the end
                  of the token, as the lexer is not stuck"))
   
   (test-case
    "Test #9"
    (check-equal? (lexer-shift (make-lexer "abc" "@xyz")) (make-lexer "abc" "@xyz")
                  "returns the given lexer as it is stuck"))
   
   (test-case
    "Test #10"
    (check-equal? (lexer-reset (make-lexer "abc" "")) (make-lexer "" "")
                  "returns a lexer with no token as the input string is empty"))
   
   (test-case
    "Test #11"
    (check-equal? (lexer-reset (make-lexer "abc" "1234")) (make-lexer "" "234")
                  "returns a lexer with the empty token and input string without its first character"))
   
   (test-case
    "Test #12"
    (check-equal? (lexer-reset (make-lexer "abc" "a%1234")) (make-lexer "" "%1234")
                  "returns a lexer with the empty token and input string without its first character"))
   )
  )


(run-tests tests 'verbose)
