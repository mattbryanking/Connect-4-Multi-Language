#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "connect4.h"

int main(int argc, char* argv[]) {
    // number of rows
    int boardHeight = 6;
    // number of columns
    int boardWidth = 7;
    // number of pieces needed to win
    int winLength = 4;
    // dynamically allocated board, basically one long array of memory locations
    char *board;
    // keeps track of which player's turn it is
    char turn;
    // turns true if the input is invalid
    int invalid = 0;


    // grabs parameters and converts them to board dimensions and win length
    // checks if arguments are provided
    if (argc > 1) {
        // if first arg is board size
        if (strstr(argv[1], "x") != NULL) {
            sscanf(argv[1], "%dx%d", &boardHeight, &boardWidth);
            
           // if second argument exists
            if (argc > 2) {
                sscanf(argv[2], "%d", &winLength);
            }
        }
        
        // if first argument is win length 
        else {
            sscanf(argv[1], "%d", &winLength);
            boardHeight = 6;
            boardWidth = 7;
        }
    }
    
    // standard board and win length conditions
    else {
        boardHeight = 6;
        boardWidth = 7;
        winLength = 4;
    }

    // dynamically allocates memory for board
    board = malloc((boardHeight * boardWidth * sizeof(char)));
    
    // places empty characters in every board location
    populateBoard(board, boardHeight, boardWidth);
    
    // sets turn to player 1
    turn = 1;

    // main game loop
    while(1) {
        // letter of column to be dropped
        char columnSelection;
       
        // boolean for if game has been won
        int win = 0;
        
        // displays current board to screen
        printBoard(board, boardHeight, boardWidth);
        
        if (invalid == 0) {
            printf("Player %d, please select your column:\n", turn);
        }
        else {
            printf("Invalid input! Please try again:\n");
        }
       
        // takes user input for column
        scanf(" %c", &columnSelection);
        
        // quits program if q is selected
        if (columnSelection == 'q' || columnSelection == 'Q') {
            //system("cls");
            free(board);
            printf("Goodbye.\n");
            exit(0);
        }

        // placePiece returns 0 if user input is invalid, skips placement
        if (placePiece(board, boardHeight, boardWidth, columnSelection, turn) != 0) {
           
            // resets invalid check
            invalid = 0;

            // only changes turn if input is valid
            if (turn == 1) {
                turn = 2;
            }
            else {
                turn = 1;
            }

            // loops through winner function, passing 4 numbers correlating to direction
            for (int i = 0; i < 4; i++) {
                win = winner(board, boardHeight, boardWidth, winLength, i);
               
                // if at any point a win is detected, the game ends
                if (win != 0) {
                    //system("cls");
                    printBoard(board, boardHeight, boardWidth);
                    free(board);
                    printf("Congratulations, Player %d. You win.\n", win);
                    exit(0);
                }
            }
           
            // if game has tied, prints message and exits
            if (checkTie(board, boardHeight, boardWidth) != 0) {
                printBoard(board, boardHeight, boardWidth);
                free(board);
                printf("Congratulations, Player %d. You tied.\n", 0);
                exit(0);
            }
        }
       
        // invalid check is set to 1 and placement is skipped
        else {
           invalid = 1;
        }
    }
}
