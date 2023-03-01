#include "connect4.h"
#include <stdio.h>

void printBoard(char* board, int rows, int columns) {
    //alphabet to reference when printing column header letters
    char alphabet[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    printf("\n");

    // prints off row letters up top
    for (int i = 0; i < columns; i++) {
        printf("%c ", alphabet[i]);
    } 

    printf("\n");

    // prints each character held at each memory location in the board
    // starts new row
    for (int i = 0; i < rows; i++) {
       
        // iterates through row
        for (int j = 0; j < columns; j++) {
            printf("%c ", *(board + i*columns + j));
        }
        printf("\n");
    }
    printf("\n");
}

void populateBoard(char* board, int rows, int columns){
   
    // starts new row
    for (int i = 0; i < rows; i++) {
        // iterates through row
        for (int j = 0; j < columns; j++) {
            *(board + i*columns + j) = '.';
        }
    }
}

int convertToColumn(char selection) {
    int column = -1;
    if (selection >= 'A' && selection <= 'Z')
        column = selection - 'A';
    else if (selection >= 'a' && selection <= 'z')
        column = selection - 'a';
    return column;
}

int placePiece(char* board, int rows, int columns, char selection, int turn) {
    int column = convertToColumn(selection);
    
    // "bottom right" (end of board malloc) is calculated to iterate backwards to start of board
    char *bottomRight = board + (sizeof(char)*rows*columns) - sizeof(char);

    // if column is invalid, returns 0 for main to re-ask
    if (column < 0 || column > columns - 1) {
        return 0;
    }
    
    // iterates vertically through selected column until empty spot is found
    for (char *i = bottomRight - (columns - column) + 1; i > board - 1; i = i - columns) {
        if (*i == '.') {
            if (turn == 1) {
                *i = 'X';
            }
            else {
                *i = 'O';
            }
            // returns 1 if placement was successful
            return 1;
        }
    }
   
    // returns 0 if placement failed (no more room in column)
    return 0;
}

// checks if every space is full
int checkTie(char* board, int rows, int columns){
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < columns; j++) {
            // if an unfilled space is found, breaks and returns 0
            if (*(board + i*columns + j) == '.') {
                return 0;
            }
        }
    }
    // returns 1 if all spaces are full
    return 1;
}

/* called by winner, depending on the direction passed to the parameter, this 
changes to iterate in the right "direction" (vertical, diagonal, etc) */
int iterateCalc(int columns, int direction) {
    int iterate;
    
    // sets iterate depending on direction
    switch (direction) {
          
        // VERTICAL
        case 0 :
            // jumps full column length
            iterate = columns;
            break;
          
        // HORIZONTAL
        case 1 :
          
            // checks straight through the array
            iterate = 1;
            break;
          
        // DIAGONAL UP LEFT
        case 2 :
          
            // adds 1 to offset one up and to the left
            iterate = columns + 1;
            break;
          
        // DIAGONAL UP RIGHT
        case 3 :
            
            // adds 1 to offset one up and to the left
            iterate = columns - 1;
            break;
    }

    return iterate;
}

// this is evil
int winner(char* board, int rows, int columns, int winNum, int direction) {
    
    // counts how many x's are found sequentially
    int xCounter = 0;
   
    // counts how many o's are found sequentially
    int oCounter = 0;
   
    // keeps track of total spaces counted and breaks when the winLength has been checked
    int checkCounter = 0;
    
    // when current board location gets too close to edge (if win length wraps around or etc)
    int edgeCounter = 0;
   
    // "bottom right" (end of board malloc) is calculated to iterate backwards to start of board
    char *bottomRight = board + (sizeof(char)*rows*columns) - sizeof(char) - sizeof(char);
    
    /* depending on the direction passed to the parameter, this 
    changes to iterate in the right "direction" (vertical, diagonal, etc) */
    int iterate = iterateCalc(columns, direction);

    // adjusts bottomright offset to make diagonals work
    if (iterate == columns - 1) {
        bottomRight = bottomRight - winNum + 1;
    }
   
    // loops through every location
    for (char *i = bottomRight + 1; i > board + winNum - 2; i--) {
        
        /* detects when current location is too close to the edge
        and jumps ahead to beginning of next row */
       
        // skips vertical, cannot wrap around edge
        if (direction != 0) {
             /* because of the initial offset for diagonal up right, 
             this jumps at the verymost left edge and positions itself 
             away from the right edge */
             if (edgeCounter == columns - winNum + 1) {
                i = i - winNum  + 1;
                edgeCounter = 0;
            }
            edgeCounter++;
        }
        
        // for every location, loops through winlength amount to check for win
        for (char *j = i; j > board - 1; j = j - iterate) {

            // adds to x counter, resets o counter
            if (*j == 'X') {
                xCounter++;
                oCounter = 0;
            }
           
            // adds to o counter, resets x counter
            else if (*j == 'O') {
                oCounter++;
                xCounter = 0;
            }
           
            // resets both counters if space is empty
            else {
                oCounter = 0;
                xCounter = 0;
            }
           
            // returns win for player 1 
            if (xCounter == winNum) {
                return 1;
            }
           
            // returns win for player 2
            else if (oCounter == winNum) {
                return 2;
            }
           
            /* stops loop when it has checked amount for win,
            this is done seperately to keep the board size safety 
            check inside the loop expression */
            checkCounter++;
            if (checkCounter == winNum) {
                checkCounter = 0;
                break;
            }
        }
       
        // resets both counters when moving to new location
        xCounter = 0;
        oCounter = 0;
    }
   
    // returns 0 if no win was found
    return 0;
}
