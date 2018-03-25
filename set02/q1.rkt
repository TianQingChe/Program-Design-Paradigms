;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(check-location "02" "q1.rkt")

(provide
   make-lexer
   lexer-token
   lexer-input
   initial-lexer
   lexer-stuck?
   lexer-shift
   lexer-reset)

;;; DATA DEFINITIONS:

;;; REPRESENTATION:
;;; a Lexer is represented as a struct (make-lexer token input)
;;; token : String  is the lexer's token string
;;; input : String  is the lexer's input string


;;; IMPLEMENTATION:
(define-struct lexer (token input))

;;; CONSTRUCTOR TEMPLATE
;; (make-lexer String String)

;;; OBSERVER TEMPLATE
;;; lexer : Lexer -> ??
(define (lexer-fn l)
  (...
   (lexer-token l)
   (lexer-input l)))

;;; FUNCTIONS

;;; make-lexer : String String -> Lexer
;;; GIVEN: two strings s1 and s2
;;; RETURNS: a Lexer whose token string is s1
;;;     and whose input string is s2
;;; DESIGN STRATEGY: Constrcutor template itself is enough, it's 
;;; redundant to create another function called "make-lexer" 

;;; lexer-token : Lexer -> String
;;; GIVEN: a Lexer
;;; RETURNS: its token string
;;; EXAMPLE:
;;;     (lexer-token (make-lexer "abc" "1234")) =>  "abc"
;;; DESIGN STRATEGY: lexer-token is defined when the lexer
;;;                  struct is defined
(begin-for-test
  (check-equal?
   (lexer-token (make-lexer "abc" "1234"))
   "abc"))


;;; lexer-input : Lexer -> String
;;; GIVEN: a Lexer
;;; RETURNS: its input string
;;; EXAMPLE:
;;;     (lexer-input (make-lexer "abc" "1234")) =>  "1234"
;;; DESIGN STRATEGY : lexer-input is defined when the lexer
;;;                   struct is defined
(begin-for-test
  (check-equal?
   (lexer-input (make-lexer "abc" "1234"))
   "1234"))

;;; initial-lexer : String -> Lexer
;;; GIVEN: an arbitrary string
;;; RETURNS: a Lexer lex whose token string is empty
;;;     and whose input string is the given string
;;; DESIGN STRATEGY: Use constructor template for Lexer
(define (initial-lexer l)
  (make-lexer "" l))

;;; lexer-stuck? : Lexer -> Boolean
;;; GIVEN: a Lexer
;;; RETURNS: false if and only if the given Lexer's input string
;;;     is non-empty and begins with an English letter or digit;
;;;     otherwise returns true.
;;; EXAMPLES:
;;;     (lexer-stuck? (make-lexer "abc" "1234"))  =>  false
;;;     (lexer-stuck? (make-lexer "abc" "+1234"))  =>  true
;;;     (lexer-stuck? (make-lexer "abc" ""))  =>  true
;;; DESIGN STRATEGY: Combine simpler functions
(define (lexer-stuck? lexer)
  (not (and (non-empty-string? (lexer-input lexer))
       (or (begin-with-letter? (lexer-input lexer))
           (begin-with-digit? (lexer-input lexer))))))
(begin-for-test
  (check-equal?
   false (lexer-stuck? (make-lexer "abc" "1234")))
  (check-equal?
   true (lexer-stuck? (make-lexer "abc" "+1234")))
  (check-equal?
   true (lexer-stuck? (make-lexer "abc" ""))))

;;; non-empty-string? : String -> Boolean
;;; GIVEN: a String
;;; RETURNS: true if the given String is non-empty;
;;;          otherwise returns false.
;;; EXAMPLES:
;;;     (non-empty-string? "") => false
;;;     (non-empty-string? "abc") => true
;;; DESIGN STRATEGY: Use system-defined function string=? 
;;;                  to compare a string with ""
(define (non-empty-string? str)
  (not (string=? str "")))
(begin-for-test
  (check-equal?
   false (non-empty-string? ""))
  (check-equal?
   true (non-empty-string? "abc")))

;;; begin-with-letter? : String -> Boolean
;;; GIVEN: a String
;;; RETURNS: true if the string begins with a letter;
;;;          otherwise returns false.
;;; EXAMPLES:
;;;     (begin-with-letter? "c1") => true
;;;     (begin-with-letter? "1c") => false
;;; DESIGN STRATEGY: Combine simpler functions
(define (begin-with-letter? str)
  (string-alphabetic? (first-char str)))
(begin-for-test
  (check-equal?
   true (begin-with-letter? "c1"))
  (check-equal?
   false (begin-with-letter? "1c")))

;;; begin-with-digit? : String -> Boolean
;;; GIVEN: a String
;;; RETURNS: true if the string begins with a digit;
;;;          otherwise returns false.
;;; EXAMPLES:
;;;     (begin-with-digit? "1c") => true
;;;     (begin-with-digit? "c1") => false
;;; DESIGN STRATEGY: Combine simpler functions
(define (begin-with-digit? str)
  (digit? (first-char str)))
(begin-for-test
  (check-equal?
   true (begin-with-digit? "1c"))
  (check-equal?
   false (begin-with-digit? "c1")))

;;; digit? : String -> Boolean
;;; GIVEN: a String
;;; RETURNS: true if all elements in the string are digits
;;; EXAMPLES:
;;;     (digit? "123") => true
;;;     (digit? "c")   => false
;;; DESIGN STRATEGY: Use the system-defined function string->number
;;;                  and the logical relation between the purpose of
;;;                  whole funcion and string->number
(define (digit? str)
  (not (false? (string->number str))))
(begin-for-test
  (check-equal? true (digit? "123"))
  (check-equal? false (digit? "c")))


;;; first-char : String -> String
;;; GIVEN: a String
;;; RETURNS: the first char of the string
;;; EXAMPLE:
;;;     (first-char "bird") => "b"
;;; DESIGN STRATEGY: Use system-defined function substring
;;;                  to get the first char
(define (first-char str)
  (substring str 0 1))
(begin-for-test
  (check-equal?
   (first-char "bird") "b"))


;;; lexer-shift : Lexer -> Lexer
;;; GIVEN: a Lexer
;;; RETURNS:
;;;   If the given Lexer is stuck, returns the given Lexer.
;;;   If the given Lexer is not stuck, then the token string
;;;       of the result consists of the characters of the given
;;;       Lexer's token string followed by the first character
;;;       of that Lexer's input string, and the input string
;;;       of the result consists of all but the first character
;;;       of the given Lexer's input string.
;;; EXAMPLES:
;;;     (lexer-shift (make-lexer "abc" ""))
;;;         =>  (make-lexer "abc" "")
;;;     (lexer-shift (make-lexer "abc" "+1234"))
;;;         =>  (make-lexer "abc" "+1234")
;;;     (lexer-shift (make-lexer "abc" "1234"))
;;;         =>  (make-lexer "abc1" "234")
;;; DESIGN STRATEGY: Combine simpler functions and constructor template
;;;                  for lexer
(define (lexer-shift lexer)
  (if (lexer-stuck? lexer) lexer
      (make-lexer (string-append (lexer-token lexer) (first-char (lexer-input lexer)))
                  (substring (lexer-input lexer) 1))))
(begin-for-test
  (check-equal?
   (lexer-shift (make-lexer "abc" "")) (make-lexer "abc" ""))
  (check-equal?
   (lexer-shift (make-lexer "abc" "+1234")) (make-lexer "abc" "+1234"))
  (check-equal?
   (lexer-shift (make-lexer "abc" "1234")) (make-lexer "abc1" "234")))

;;; lexer-reset : Lexer -> Lexer
;;; GIVEN: a Lexer
;;; RETURNS: a Lexer whose token string is empty and whose
;;;     input string is empty if the given Lexer's input string
;;;     is empty and otherwise consists of all but the first
;;;     character of the given Lexer's input string.
;;; EXAMPLES:
;;;     (lexer-reset (make-lexer "abc" ""))
;;;         =>  (make-lexer "" "")
;;;     (lexer-reset (make-lexer "abc" "+1234"))
;;;         =>  (make-lexer "" "1234")
;;; DESIGN STRATEGY: Combine simpler functions and use constrcutor template
;;;                  for lexer
(define (lexer-reset lexer)
  (if (not (non-empty-string? (lexer-input lexer)))
      (make-lexer "" "")
      (make-lexer "" (substring (lexer-input lexer) 1))))
(begin-for-test
  (check-equal?
   (lexer-reset (make-lexer "abc" "")) (make-lexer "" ""))
  (check-equal?
   (lexer-reset (make-lexer "abc" "+1234")) (make-lexer "" "1234")))
