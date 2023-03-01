(require 'regex)
(include-relative "connect4_engine.scm")

(define (int-to-char i)
  (integer->char (+ i 65))
)

(define (string-to-int s)
  (- (char->integer (string-ref s 0)) 65)
)

; boilerplate code from Zachary Kurmas
(define (parse-size size)
  (define result (cdr (regex-match  #/(\d+)x(\d+)/ size)))
  (cond
    ((not result) (display (format "\"~A\" is not a valid board size" size)) (exit))
    (else (map (lambda (x) (string->number x)) result))
  )
)

; boilerplate code from Zachary Kurmas
(define (parse-win-length win_length)
 (define result (regex-match #/\d+/ win_length))
 (cond 
  ((not result) (display (format "\"~A\" is not a valid win length" win_length)) (exit))
  (else (string->number win_length))
 )
)

; main game loop. valid is used to throw an error message when a column is full, takes 1 or 0
(define (play-connect-4 num_rows num_columns win_length board turn valid)

    ; if first turn and board is empty, make one and run again
    (if (equal? board () )
        (play-connect-4 
            num_rows 
            num_columns 
            win_length 
            (make-board (* num_rows num_columns) board) 
            "X" 
            1)
            
        (begin 

            ; prints current board layout
            (show-all 
                num_columns 
                (reverse board) 
                (* num_rows num_columns) 
                0)

            ; gets column from user
            (let ((input (get-selection num_columns valid)))

                ; if 'q'/'Q' was inputted by user
                (if (= input -1)
                    (display "Goodbye.\n")

                    ; makes new board with selected piece placed
                    (let ((new_board (place-piece 
                        turn 
                        input 
                        num_columns 
                        num_rows                                 
                        board 
                        1)))
                            
                        ; checks win conditions
                        (cond 
                                
                            ; if selected column is full (making board unchanged), redo turn
                            ((equal? board new_board)
                                (play-connect-4 
                                    num_rows 
                                    num_columns 
                                    win_length 
                                    new_board 
                                    turn 
                                    0))
                            
                            ; if player won, declare win and end game
                            ((= 1 (winner 
                                new_board 
                                num_rows 
                                num_columns 
                                win_length 
                                0))

                                (begin
                                    (show-all 
                                        num_columns 
                                        (reverse new_board) 
                                        (* num_rows num_columns) 
                                        0) 

                                    (if (equal? turn "X")
                                        (display "Congratulations, Player 1. You win.\n")
                                        (display "Congratulations, Player 2. You win.\n")
                                    )
                                    (exit)
                                ))
                                
                            ; if board is full with no winner, declare tie
                            ((= 1 (check-tie 0 num_columns num_rows new_board))
                                (begin
                                (show-all 
                                    num_columns 
                                    (reverse new_board) 
                                    (* num_rows num_columns) 
                                    0) 
                                (display "You tied! Thanks for playing.\n\n")
                                (exit)
                                ))

                            ; if no win condition is found, continue game
                            (else
                                (play-connect-4 
                                    num_rows 
                                    num_columns 
                                    win_length 
                                    new_board 
                                    (next-turn turn) 
                                    1))
                        )
                    )
                )
            )
        )
    )
)

; boilerplate code from Zachary Kurmas
(define num_args (vector-length command-line-arguments))
(cond 
    ((= 0 num_args) 
        (play-connect-4 6 7 4 '() "X" 1))  ; play a default 6x7 game of Connect 4.
    ((= 1 num_args) 
        (apply play-connect-4 (append 
            (parse-size (vector-ref command-line-arguments 0)) 
            (list 4)
            (list '()) 
            (list "X")
            (list 1))))
    (else 
        (apply play-connect-4 (append 
            (parse-size (vector-ref command-line-arguments 0)) 
            (list (parse-win-length (vector-ref command-line-arguments 1))) 
            (list '())
            (list "X")
            (list 1)))
    )
)
