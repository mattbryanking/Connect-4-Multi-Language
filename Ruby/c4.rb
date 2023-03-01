require_relative './connect4'

rows = 6
cols = 7
win_length = 4

if ARGV.length >= 1
    if ARGV[0].strip =~ /^(\d+)x(\d+)$/
        rows = $1.to_i
        cols = $2.to_i
    else
        puts "Board size \"#{ARGV[0]}\" is not formatted properly."
        exit
    end
end

if ARGV.length >= 2
    if ARGV[1].strip =~ /^(\d+)$/
        win_length = $1.to_i
    else
        puts "Win length must be an integer"
        exit
    end
end

c4 = Connect4.new(rows, cols, win_length)
c4.play_game
