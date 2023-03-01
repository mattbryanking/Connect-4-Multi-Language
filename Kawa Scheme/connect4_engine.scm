; gets element from list at desired location
(define (get n lst)
    (if (null? lst) 
        #f 
        (if (= n 0) 
            (car lst) 
            (get (- n 1) (cdr lst))))
)

; asks for input from user and converts for use in game
(define (get-selection num_columns valid)

    ; displays invalid 
    (if (= valid 1)
      (display "Please select a column:\n")
      (display "Invalid column! Try again:\n")
    )

    ; converts input to integer
    (let ((selection (string-to-int(read-line))))
        (cond

            ; if selection is Q, return -1 and quit game
            ((or (= selection 16) (= selection 48))
                -1)

            ; uppercase
            ((and (>= selection 0) (< selection num_columns))
                (- (- num_columns selection) 1))
            
            ; lowercase
            ((and (>= selection 32) (< selection (+ num_columns 32)))
                (- (- num_columns (-  selection 32)) 1))

            ; if selection is invalid, call again with valid set to 0
            (else
                (get-selection num_columns 0))
        )
    )
)

; fills empty array of specified length with "." 
(define (make-board n lst)
    (if (= n 0)
        lst
        (make-board (- n 1) (append '(".") lst))
    )
)

; prints column letter values before board is displayed
(define (print-alphabet n num_columns)
    (if (= n 0)
        (newline)
    )
    (if (< n num_columns)
        (let ((alphabet '(A B C D E F G H
                          I J K L M N O P 
                          Q R S T U V W X Y Z)))
            (display(format "~2A" (get n alphabet)))
            (print-alphabet (+ n 1) num_columns)
        )
    )
)

; prints formatted board
(define (show-board num_columns lst n)

    ; when enough are printed to fill a row,
    ; print a newline
    (if (= (modulo n num_columns) 0)
        (newline)
    )
    (if (<= n 0)
        lst
        (begin 
            (display(format "~2A" (car lst)))
            (show-board num_columns (cdr lst) (- n 1))
        )
    )
)

; combines functions to avoid repeated code
(define (show-all num_columns lst n i)
    (print-alphabet i num_columns)
    (show-board num_columns lst n)
)   

; drops piece in specified column, returns new list, 
; must be initially called with loop_over as 0
(define (place-piece val n num_columns num_rows lst loop_over)
    (let ((max (+ (* (* num_rows num_columns) -1) num_columns)))
        (if (>= n max)

            ; if location in initial row is reached
            (if (<= n 0)
                (begin

                    ; if spot is open and column iteration is over
                    (if (and (equal? (car lst) ".") (= loop_over 1))
                        (cons val (cdr lst))

                        ; loops until next row in same column is reached
                        (if (= (modulo (- n 1) num_columns) 0)
                            (cons (car lst) (place-piece 
                                val 
                                (- n 1) 
                                num_columns 
                                num_rows 
                                (cdr lst) 
                                1))
                            (cons (car lst) (place-piece 
                                val 
                                (- n 1) 
                                num_columns 
                                num_rows 
                                (cdr lst) 
                                0))
                        )
                    )
                )

                ; iterates through board until column is reached
                (cons (car lst) (place-piece val 
                    (- n 1) 
                    num_columns 
                    num_rows 
                    (cdr lst) 
                    1))
            )

        ; returns original list if placement fails (column is full)
        lst
        )
    )
)

; returns list with all elements reversed
(define (reverse lst)
    (if (null? lst)
        lst
        (append (reverse (cdr lst)) (list (car lst)))))

; changes turn in main game loop
(define (next-turn turn)
    (if (equal? turn "X")
        "O"
        "X"
    )
) 

; replaces chosen element with inputted value
(define (reset val n lst)
    (if (= n 0)
        (cons val (cdr lst))
        (cons (car lst) (reset val  (- n 1) (cdr lst)))
    )
)

; checks board to determine if players have tied
(define (check-tie n num_columns num_rows lst)

    ; number of spaces on board
    (let ((max (* num_columns num_rows)))
        (if (< n max)

            ; if "." is found, moves can still be made
            (if (equal? "." (get n lst))
                0
                (check-tie (+ n 1) num_columns num_rows lst)
            )
        1
        )
    )
)

; checks a single list of elements for a win 
; condition, given by get-row. val can be
; anything as it gets changed within function
(define (row-check lst n val)
    (cond

        ; passed by get-row, if row is invalid
        ((equal? 0 lst)
            0)

        ; if empty space is found
        ((equal? val ".")
            0)

        ; if all elements of list are the same
        ((null? lst)
            1)

        ; sets first value in list to check against
        ((= n 0)
            (row-check (cdr lst) (+ n 1) (car lst))) 

        ; if current val doesn't match first value, return 0
        (else
            (if (equal? val (car lst))
                (row-check (cdr lst)  (+ n 1) val)
                0
            )
        )
    )
)

; prepares list of win_length length for row-check to check
(define (get-row board num_columns win_length n i length index iterate lst)
    (cond 

        ; returns prepared list once win_length elements are added
        ((>= i win_length)
            lst)

        ; returns 0 if row would go outside board bounds
        ((>= n length)
            0)
            
        ; loops to initial point before assembling list
        ((< n index)
            (get-row 
                (cdr board) 
                num_columns 
                win_length 
                (+ n 1) 
                i 
                length 
                index 
                iterate 
                ()))

        ; adds first element of row to list
        ((= n index)
            (get-row 
                (cdr board) 
                num_columns 
                win_length 
                (+ n 1) 
                (+ i 1) 
                length 
                index 
                iterate 
                (append (list (car board)) lst)))

        ; iterates through board until next element for list is reached
        (else 
            (if (= 0 (modulo (- n index) iterate))
                (get-row 
                    (cdr board) 
                    num_columns 
                    win_length 
                    (+ n 1) 
                    (+ i 1) 
                    length 
                    index 
                    iterate 
                    (append (list (car board)) lst))
                (get-row 
                    (cdr board) 
                    num_columns 
                    win_length 
                    (+ n 1) 
                    i 
                    length 
                    index 
                    iterate 
                    lst)
            )
        )
    )
)

; checks every space on board in given direction, and calls get-row and row-check on each
(define (parse-win board num_columns win_length n length direction iterate)

    ; if every space has been checked without a win, return 0
    (if (>= n length)
        0

        ; returns 1 if win has been found, iterates to next space if not
        (if (and 

                ; if space won't wrap across edge of board
                (= 1 (column-calc 
                        n 
                        num_columns 
                        win_length 
                        direction))

                ; if row in given direction has win_length of the same piece in a row
                (= 1 (row-check 
                    (get-row 
                        board 
                        num_columns 
                        win_length 
                        0 
                        0 
                        length 
                        n 
                        iterate 
                        '()) 0 0)))
                1
                (parse-win 
                    board 
                    num_columns 
                    win_length 
                    (+ n 1) 
                    length 
                    direction 
                    iterate)
        )
    )
)

; helper function to determine how far to iterate through board depending on direction
(define (iterate-calc direction num_columns)
    (cond

        ; vertical
        ((= direction 0)
            num_columns)
        
        ; horizontal
        ((= direction 1)
            1)

        ; diagonal left
        ((= direction 2)
            (+ num_columns 1))

        ; diagonal right
        ((= direction 3)
            (- num_columns 1))
    )
)

; helper function to determine if row in given direction will wrap around edge
(define (column-calc n num_columns win_length direction)

    ; direction check
    (cond

        ; horizontal and diagonal left
        ((or (= direction 1) (= direction 2))

            ; modulo n num_columns gets the current column
            (if (<= (modulo n num_columns) (- num_columns win_length))
                1
                0
            )
        )

        ; diagonal right
        ((= direction 3)

            ; modulo n num_columns gets the current column
            (if (>= (modulo n num_columns) (- win_length 1))
                1
                0
            )
        )
        
        ; vertical
        (else
            1
        )
    )
)

; main function called to parse board in all 4 directions
(define (winner board num_rows num_columns win_length direction)

    ; returns 0 if no win is found
    (if (>= direction 4)
        0
        
        ; returns 1 if win is found, goes to next direction otherwise
        (if (= 1 (parse-win 
            board 
            num_columns 
            win_length 
            0 
            (* num_rows num_columns) 
            direction 
            (iterate-calc direction num_columns)))

            1
            (winner 
                board 
                num_rows 
                num_columns 
                win_length 
                (+ direction 1))
        )
    )
)
