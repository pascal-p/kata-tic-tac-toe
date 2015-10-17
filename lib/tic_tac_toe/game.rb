require_relative './shared/game_parms'

module TicTacToe

  class Game

    def initialize(board=TicTacToe::Board.new(),
                   p1=Player.new(name: 'foo', type: TicTacToe::Shared::GameParms::O),
                   p2=Player.new(name: 'bar', type: TicTacToe::Shared::GameParms::X))
      @board = board
      @player1 = p1
      @player2 = p2
    end

    #
    # return the name of the winner or :draw 
    #
    def play
      outcome = ''
      c_player, o_player = _init_players
      #
      loop do
        STDOUT.puts(@board.to_s)   # draw game
        loop do            # current player do his move
          m, sym = _get_move_from(c_player) 
          break if @board.set_cell(m, sym) == sym
          STDERR.print "! cell already set, try something else\n"
        end
        outcome = @board.game_over?
        break if outcome == :draw || outcome == :winner
        c_player, o_player = _switch_players(c_player, o_player)
      end
      _conclusion(outcome, c_player)
    end
    
    private
    def _get_move_from(c_player)
      m = 0
      loop do
        STDOUT.print ">> player: #{c_player.name} #{c_player.type} move [1..9]? "
        m = STDIN.gets.chomp.to_i
        break if m.to_i > 0 && m.to_i <= 9
        STDOUT.print ">> ! illegal input - valid input is a digit in [1..9]\n"
      end
      return [m, c_player.type]
    end
    
    def _init_players
      i = rand(2) + 1  # 1..2
      j = 3 - i        # 2..1
      raise ArgumentError,
            "i and j are supposed to be in [1..2], " +
            "got i: #{i.inspect} and j: #{j.innpect}"  if i == 0 ||
                                                          i > 2 ||
                                                          j == 0 ||
                                                          j > 2
      [ self.instance_variable_get("@player#{i}"),
        self.instance_variable_get("@player#{j}") ]
    end
    
    def _switch_players(c_play, o_play)
      return [o_play, c_play]
    end

    def _conclusion(outcome, c_player)
      STDOUT.print("#{@board}\n") 
      outcome_s =
        if outcome == :winner
          "#{c_player}.name won"        
        else
          outcome.to_s
        end
      STDOUT.print("\n\t==> #{outcome_s}\n")      
    end
    
  end

end
