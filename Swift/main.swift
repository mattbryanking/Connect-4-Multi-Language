// standard import
import Foundation

// includes exit()
import Darwin

// grabs and computes command line arguments to correctly start game
func startGame() {
    var rows = 6
    var columns = 7
    var winLength = 4
    
    // argument 1 is program call
    if CommandLine.argc > 1 {
        
        let size = CommandLine.arguments[1]
        
        // swift regex requires a regex pattern object, NSRegExp
        let range = NSRange(location: 0, length: size.utf16.count)
        let regex = try? NSRegularExpression(pattern: #"(\d+)x(\d+)"#)
        
        // returns true if size is included in args and correctly formatted
        let match = regex!.firstMatch(in: size, range: range) != nil
        
        if (match) {
            
            // dissassembling NumxNum format
            let sizeList = Array(size)
            rows = sizeList[0].wholeNumberValue!
            columns = sizeList[2].wholeNumberValue!
            
            // if invalid win length, set to default 4
            if CommandLine.argc > 2 {
                winLength = Int(CommandLine.arguments[2])! > 0 ? Int(CommandLine.arguments[2])! : 4
            }
        }
        else {
            print("Board size \(size) is not formatted correctly.")
            exit(1)
        }
    }
    
    // enter main game loop
    let connect4 = Board(rows: rows, columns: columns, winLength: winLength)
    connect4.playGame()
    
}

class Board {
    let rows: Int
    let columns: Int
    let winLength: Int
    let size: Int
    
    // board is a single list, formatted in printBoard
    var board: [String] = []
    
    // referenced multiple times, easier to store in variable
    let empty = ". "
    
    // keeps track of turn
    var player = 1
    
    // board initializer
    init(rows: Int, columns: Int, winLength: Int) {
        self.rows = rows
        self.columns = columns
        self.winLength = winLength
        self.size = rows * columns
        
        // fills board with empty pieces
        self.board = [String](repeating: empty, count: size)
    }
    
    // returns header adjusted for board size
    func header() -> Substring {
        return "\nA B C D E F G H I J K L M N O P".prefix(columns * 2)
    }
    
    // prints formatted board
    func printBoard() {
        print(header())
        
        // board is reversed for user so backwards iteration is not needed
        for (index, piece) in board.reversed().enumerated() {
            print(piece, terminator: "")
            
            // starts new row
            if ((index + 1) % columns == 0) {
                print()
            }
        }
    }
    
    // drops piece in selected column
    func placePiece(column: Int) -> Bool {
        
        // iterates upward from selected column, entering when empty space is found
        for i in stride(from: column, to: size, by: columns) where board[i] == empty {
            
            // places correct piece and returns true
            board[i] = player == 1 ? "X " : "O "
            return true
        }
        
        // returns false if no valid empty space was found
        return false
    }
    
    // checks user input to see if valid
    func isValid(input: String) -> Bool {
        
        // seperate to avoid error converting weird strings to char
        if (input.count != 1 ) {
            return false
        }
        
        // checks if input is letter and within bounds of board
        let column = Int(Character(input.uppercased()).asciiValue!) - 65
        return (column >= 0 && column < columns) && Character(input).isLetter
    }
    
    // determines if game has tied
    func isTie() -> Bool {
        
        // if empty piece is found, return false
        for piece in board where piece == empty {
            return false
        }
        
        // return true if no pieces are empty
        return true
    }
    
    // determines if game has been won
    func isWin() -> Bool {
        
        // checks all 4 directions
        for direction in 0...3 {
            
            // amount to iterate through array to find next piece in direction
            let iterate = iterateCalc(direction: direction)
            
            // checks in current direction for non-empty pieces
            for i in 0...(size - 1) where board[i] != empty {
                
                // create row to be checked
                var row = [String]()
                
                if ((direction == 0) ||
                    
                    // if current direction is 1 or 2 on valid spaces
                    ((direction == 1 || direction == 2) && (i % columns <= columns - winLength)) ||
                    
                    // if current direction is 3 on valid spaces
                    (direction == 3 || (i % columns >= winLength - 1))) {
                    
                    // creates row in current direction
                    for j in 0...(winLength - 1) {
                        
                        // saftey check to avoid out of bounds error
                        if ((i + (iterate * j)) >= size) {
                            
                            // sets row to empty and ends loop
                            row = [String]()
                            break;
                        }
                        row.append(board[i + (iterate * j)])
                    }
                    
                    // isEmpty check to avoid a false positive on empty list
                    if (!row.isEmpty && rowCheck(row: row)) {
                        
                        // return true if win is found
                        return true
                    }
                }
            }
        }
        
        // return false if no win was found
        return false
    }
    
    // checks row passed by isWin for win condition
    func rowCheck(row: [String]) -> Bool {
        
        // saftey check to avoid all empty counted as win
        if (row[0] != empty) {
            
            // returns false if piece not matching 1st is found
            for piece in row where piece != row[0] {
                return false
            }
            return true
        }
        return false
    }
    
    // called by is_win, depending on the direction passed to the parameter, this
    // changes to iterate in the right "direction" (vertical, diagonal, etc)
    func iterateCalc(direction: Int) -> Int  {
        switch direction {
            
        // vertical
        case 0:
            return columns
        
        // horizontal
        case 1:
            return 1
        
        // diagonal up left
        case 2:
            return columns + 1
            
        // diagonal up right
        case 3:
            return columns - 1
            
        // throws error and aborts if direction is invalid
        default:
            print("Error calculating iteration amount, aborting.")
            exit(1)
        }
    }
    
    // main game loop
    func playGame() {
        
        // initial message, will change over time.
        // stored in a variable to avoid messy code
        var message = "Player \(player), which Column?"
        
        while (true) {
            
            // prints board and prompt
            printBoard()
            print(message)
            
            // get user selection
            let input = readLine()
            
            // if user inputs q or Q, game is quit
            if (input?.uppercased().contains("Q") == true) {
                print("Goodbye")
                exit(0)
            }
            
            // continues if input is valid
            else if (isValid(input: input!)) {
                
                // converts input into correct num for board
                let column = columns - (Int(Character(input!.uppercased()).asciiValue!) - 65) - 1
                
                // continues if piece placement is successful
                if (placePiece(column: column)) {
                    
                    // changes player
                    player = player == 1 ? 2 : 1
                    message = "Player \(player), which Column?"
                    
                    // checks for win
                    if (isWin()) {
                        printBoard()
                        player = player == 1 ? 2 : 1
                        print("Congratulations, Player \(player). You win.")
                        exit(0)
                    }
                    
                    // checks for tie
                    if (isTie()) {
                        printBoard()
                        print("You tied! Try again!")
                        exit(0)
                    }
                }
                
                // if piece placement failed (column full)
                else {
                    message = "Column \(input!.uppercased()) is full! Player \(player), Please try again."
                }
            }
            
            // if input was invalid
            else {
                message = "Invalid input! Player \(player), Please try again."
            }
        }
    }
}

// call to start program
startGame()