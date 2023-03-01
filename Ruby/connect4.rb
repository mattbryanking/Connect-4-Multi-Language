class Connect4

    def initialize(num_rows, num_columns, win_length) 
        @num_rows = num_rows
        @num_columns = num_columns
        @win_length = win_length
        @size = num_columns * num_rows
        @player = 1;

        # used to define an empty space
        @empty = ". "

        # initial message, will be modified depending on input
        @message = "Player " + @player.to_s() + ", which Column?"

        # chain
        # board is a single list, formatted in print_board()
        @board = Array.new(@size).fill(@empty)
    end

    def header
        "A B C D E F G H I J K L M N O P"[0, @num_columns*2]
    end

    def print_board
        
        # formats and prints letters above board
        puts "\n" + header()

        # chain
        # reverses board and prints each piece/space
        @board.reverse.each_with_index do |piece, i|
            print piece
            
            # starts new row
            if (i + 1) % @num_columns == 0
                puts
            end
        end
    end

    def place_piece(column)

        # chain
        # steps through board vertically
        column.step(@size, @num_columns).each do |i|
            if @board[i] == @empty

                # places correct piece based on turn
                @board[i] = @player == 1 ? "X " : "O "
                return true
            end
        end

        return false
    end

    # checks if inputted space is valid
    def is_valid(column)

        # if null (user presses enter immediatly)
        if column.empty?
            return false
        end

        # chain 
        # calculates selection and determines if it is in bounds
        num = @num_columns - (column.upcase().ord() - 65) - 1
        in_bounds = (num >= 0 and num < @num_columns)
        
        # in_bounds and if selection is a letter
        return (in_bounds and column.match?(/[[:alpha:]]/))
    end

    # checks if every space is full
    def is_tie
        @board.each do |piece|

            # if empty space is found, return false
            if piece == @empty
                return false
            end
        end

        return true
    end

    # called by is_win, depending on the direction passed to the parameter, this 
    # changes to iterate in the right "direction" (vertical, diagonal, etc) 
    def iterate_calc(direction) 
        case direction

            # VERTICAL
            when 0 
                @num_columns  

            # HORIZONTAL
            when 1              
                1

            # DIAGONAL UP LEFT
            when 2           
                @num_columns + 1
              
            # DIAGONAL UP RIGHT
            when 3 
                @num_columns - 1
        end
    end

    # creates lists for row_check to parse for a win
    def is_win()

        # goes through all 4 directions
        (0..3).each do |direction|
            iterate = iterate_calc(direction)

            # all board locations
            (0..(@size - 1)).each do |i|
                list = Array.new()
             
                # big if statement to make sure rows don't wrap around edge
                if (direction == 0) or 

                    # if direction is 1 or 2 on valid spaces
                    ((direction == 1 or direction == 2) and 
                        (i % @num_columns <= @num_columns - @win_length)) or 

                    # if direction is 3 on valid spaces
                    (direction == 3 and (i % @num_columns >= @win_length - 1))

                    # creates list to be checked for win
                    (0..(@win_length - 1)).each do |j|
                        list.push(@board[i + (iterate * j)])
                    end

                    # returns true if winning row is found
                    if row_check(list)
                        return true
                    end
                end
            end
        end

        # returns false if no win was found
        return false
    end

    # checks rows created by is_win
    def row_check(row)

        # if first space is empty
        if (row[0] == @empty)
            return false
        end

        # if all spaces are same as first
        row.each do |piece|
            if (piece != row[0])
                return false
            end
        end

        # returns true if all pieces are the same
        return true
    end

    # main game loop
    def play_game
        while true

            # prints board current message
            print_board()
            puts @message

            # chain
            # gets user input, STDIN to avoid taking args
            column = STDIN.gets.chomp()
        
            # quits game if q is inputted
            if column.upcase() == "Q"
                puts "Goodbye."
                break;

            elsif is_valid(column)

                # chain
                # adjusts inputted letter to correct number
                column = @num_columns - (column.upcase().ord() - 65) - 1

                # if piece placement was successful (column not full)
                if place_piece(column)

                    # changes player and adjusts message for next turn
                    @player = @player == 1 ? 2 : 1
                    @message = "Player " + @player.to_s() + ", which Column?"
                else

                    # adjusts message and does not change player, repeat turn
                    @message = "Invalid input! Player " + @player.to_s() + ", Please try again."
                end

                # if win condition is found
                if is_win()
                    print_board()

                    # adjusts player for win message (changed previously after piece placement)
                    @player = @player == 1 ? 2 : 1
                    puts "Congratulations, Player " + @player.to_s() + ". You win."
                    break;

                # if game ends in tie
                elsif is_tie()
                    print_board()
                    puts "You tied! Try again!"
                    break;
                end

            # if input is not valid
            else
                @message = "Invalid input! Player " + @player.to_s() + ", Please try again."
            end
        end 
    end
end
