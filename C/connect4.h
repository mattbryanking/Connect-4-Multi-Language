#ifndef CONNECT4_H
#define CONNECT4_H

void printBoard(char* board, int rows, int columns);
void populateBoard(char* board, int rows, int columns);
int placePiece(char* board, int rows, int columns, char selection, int turn);
int convertToColumn(char selection);
int winner(char* board, int rows, int columns, int winNum, int direction);
int checkTie(char* board, int rows, int columns);
int iterateCalc(int columns, int direction);

#endif
