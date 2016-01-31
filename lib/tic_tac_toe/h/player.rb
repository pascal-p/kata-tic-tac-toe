require_relative '../shared/game_parms'
require_relative '../base/player'

module TicTacToe

  module H
  
    class Player < Base::Player
      
      def get_move
        m = -1
        loop do
          STDOUT.print ">> player: #{@name} #{@type} move in #{@@game_parms::POS.inspect}? "
          m = STDIN.gets.chomp.to_i
          break if m.to_i > 0 && m.to_i <= @@game_parms::DIM * @@game_parms::DIM
          STDOUT.print ">> ! illegal input - valid input is a digit in #{@@game_parms::POS.inspect}\n"
        end
        m
      end
    
    end

  end
  
end
