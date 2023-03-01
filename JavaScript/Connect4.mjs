import { exit } from "process"; 
import * as readline from 'node:readline';

const io = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

export default class Connect4 {

    #numRows;
    #numCols;
    #winLength;
    #size;
    #board;

    constructor(numRows, numCols, winLength) {         
        console.log(`Constructor ${numRows}  ${numCols}  ${winLength}`)   
        this.#numCols = numCols;
        this.#numRows = numRows;
        this.#winLength = winLength;
        
        this.#size = this.#numCols * this.#numRows;

        // board is a single list, formatted in printBoard()
        this.#board = Array(this.#size).fill(". ");
    }

    header() {
        return 'A B C D E F G H I J K L M O P'.substring(0, this.#numCols * 2);
    }

    printBoard() {
        
        // formats and prints letters above board
        console.log("\n" + this.header());

        // prints each character in board
        for (let i = 0; i < this.#size; i++) {
                io.write(this.#board[i]);

                // starts new row
                if ((i + 1) % this.#numCols == 0) {
                    io.write('\n');
                }
        }
        console.log();
    }

    placePiece(player, column) {
        for (let i = column; i >= 0; i -= this.#numCols) {
            if (this.#board[i] === ". ") {

                // places correct piece based on turn
                this.#board[i] = player == 1 ? "X " : "O ";
                return 1;
            }
        }

        // if no spots in column are open, return 0
        return 0;
    }

    // checks if every space is full
    checkTie(){
        for (let i = 0; i < this.#size; i++) {

            // if empty space is found, return 0
            if (this.#board[i] === ". ") {
                return 0;
            }
        }
        return 1;
    }

    /* called by winner, depending on the direction passed to the parameter, this 
    changes to iterate in the right "direction" (vertical, diagonal, etc) */
    iterateCalc(direction) {
        let iterate;
        
        // sets iterate depending on direction
        switch (direction) {
              
            // VERTICAL
            case 0 :
                // jumps full column length
                iterate = this.#numCols;
                break;
              
            // HORIZONTAL
            case 1 :
              
                // checks straight through the array
                iterate = 1;
                break;
              
            // DIAGONAL UP LEFT
            case 2 :
              
                // adds 1 to offset one up and to the left
                iterate = this.#numCols + 1;
                break;
              
            // DIAGONAL UP RIGHT
            case 3 :
                
                // adds 1 to offset one up and to the left
                iterate = this.#numCols - 1;
                break;
        }
    
        return iterate;
    }

    // creates lists for rowCheck to parse for a win
    winner() {
        let iterate;

        // goes through all four directions
        for (let direction = 0; direction < 4; direction++) {
            iterate = this.iterateCalc(direction);

            // all board locations
            for (let j = 0; j < this.#size; j++) {
                let list = Array();

                // big if statement to make sure rows dont wrap around edge
                if (
                    (direction == 0)
                    
                    // if directions 1 or 2 on valid spaces
                    || ((direction == 1 || direction == 2) &
                       j % this.#numCols <= this.#numCols - this.#winLength)
                    
                    // if direction 3 on valid spaces
                    || (direction == 3 & (j % this.#numCols >= this.#winLength - 1))) {
                        
                        // creates list to be checked for win
                        for (let k = 0; k < this.#winLength; k++) {
                            list.push(this.#board[j + (iterate * k)]);
                        }

                        // returns 1 if win is found
                        if (this.rowCheck(list) == 1) {
                            return 1;
                        }
                     }
            
            }
        }
    }

    // checks rows created by winner() for win conditions
    rowCheck(row) {

        // sets reference piece to check against
        let first = row[0];

        for (let i = 0; i < row.length; i++) {
            if (row[i] !== first || row[i] === ". ") {
                return 0;
            }
        }

        // returns 1 if all pieces are the same
        return 1;
    }
    

    quit() {
        console.log("Goodbye.");
        io.close();
        exit();
    }

    // main game loop, uses callbacks to loop through
    playGame(player, message, callback) {
        this.printBoard();

        // parameter to track which message to show
        message = message == 0 ? `Player ${player}, which Column? ` : "Invalid input! Please try again: ";

        io.question(message, line => {

            let column = line.toUpperCase().charCodeAt(0) - 65;

            // quits if q is entered
            if (line === "q") {
                this.quit();
            }

            // if input is not a letter, the first boolean will return true, as symbols 
            // and numbers don't have cases
            if (line.toLowerCase() === line.toUpperCase() || column >= this.#numCols) {
                callback(this.playGame(player, 1, callback));
            }

            // if input is valid
            else if ((this.placePiece(player, (this.#size - (this.#numCols - column)))) == 1) {

                // if a player wins
                if (this.winner() == 1) {
                    this.printBoard();
                    console.log(`Congratulations, Player ${player}. You win.`);
                    io.close();
                    exit();
                }

                // if board is full without win
                if (this.checkTie() == 1) {
                    this.printBoard();
                    console.log("You tied! Try again!");
                    io.close();
                    exit();
                }

                // changes turn
                player = player == 1 ? 2 : 1;
                callback(this.playGame(player, 0, callback));

            }

            // catch-all just in case something weird happens
            else {
                callback(this.playGame(player, 1, callback));
            }
        })
    }
}
