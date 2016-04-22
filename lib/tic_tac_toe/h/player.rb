require_relative '../shared/game_parms'
require_relative '../base/player'

module TicTacToe

  module H
  
    class Player < Base::Player
      
      def get_move(already_played = [])
        m = -1
        ary = @@game_parms::POS - already_played
        loop do
          STDOUT.print ">> player: #{@name} #{@type} move in #{ary.inspect}? "
          m = STDIN.gets.chomp.to_i
          break if m.to_i > 0 && m.to_i <= @@game_parms::DIM * @@game_parms::DIM
          STDOUT.print ">> ! illegal input - valid input is a digit in #{ary.inspect}\n"
        end
        m
      end
    
    end

  end
  
end
