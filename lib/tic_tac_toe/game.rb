require_relative './shared/game_parms'

module TicTacToe

  class Game

    @@game_parms = TicTacToe::Shared::GameParms.setup()
    
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
      [1, 2].each {|ix| _select_players(ix)}
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
      return [c_player.get_move(@board), c_player.type]
    end
    
    def _select_players(ix)
      ans, name = '', ''
      #
      STDOUT.print "++ Player #{ix}\n"
      #
      loop do
        STDOUT.print "- Player #{ix} (H)uman or (A)I ?"
        ans = STDIN.gets.chomp.upcase
        break if ['H', 'A'].include?(ans)
      end
      #
      if ans == 'H'
        loop do
          STDOUT.print "- Enter your name? "
          name = STDIN.gets.chomp.capitalize
          STDOUT.print "- is #{name} correct (Y/N)? "
          ans = STDIN.gets.chomp.upcase
          break if ans == 'Y' || ans == ''
        end
        self.instance_variable_set("@player#{ix}",
                                   HPlayer.new(name: name,
                                               type: ix == 1 ? @@game_parms::O : @@game_parms::X))
      else
        # IA
        self.instance_variable_set("@player#{ix}",
                                   IAPlayerS.new(name: "IA#{ix}",
                                                 type: ix == 1 ? @@game_parms::O : @@game_parms::X))
      end
    end

    def _init_players
      i = rand(@@game_parms::MAX_PLAYER) + 1  # 1..2
      j = (@@game_parms::MAX_PLAYER + 1) - i  # 3 - i ==> 2..1
      raise ArgumentError,
            "i and j are supposed to be in [1..#{TicTacToe::Shared::MAX_PLAYER}], " +
            "got i: #{i.inspect} and j: #{j.inspect}"  unless [1, @@game_parms::MAX_PLAYER].include?(i) &&
                                                              [1, @@game_parms::MAX_PLAYER].include?(j)
      [ self.instance_variable_get("@player#{i}"),
        self.instance_variable_get("@player#{j}") ]
    end

    def _switch_players(c_play, o_play)
      return [o_play, c_play]
    end

    def _conclusion(outcome, c_player)
      STDOUT.print("#{@board}\n")
      outcome_s = (outcome == :winner) ?
                    "#{c_player.name} won" : outcome.to_s
      STDOUT.print("\n\t==> #{outcome_s}\n")
    end

  end

end
