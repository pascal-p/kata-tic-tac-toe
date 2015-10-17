require_relative './shared/game_parms'

module TicTacToe

  class Player

    attr_reader :name, :type

    @@nb_player     = 0
    
    def initialize(input)
      @game_parms = TicTacToe::Shared::GameParms.setup
      raise ArgumentError,
            "no more than #{@game_parms::MAX_PLAYER} allowed" if @@nb_player >= @game_parms::MAX_PLAYER
      raise ArgumentError,
            "input hash should be defined and not empty" if input == {} || !input.is_a?(Hash)
      #
      @name = input.fetch(:name) { "foo_#{rand(100)}" }
      @type = input.fetch(:type) { @game_parms.poss_type.collect {|k, v| k if v == 0} }
      @game_parms.poss_type[@type] = 1
      @@nb_player += 1
    end

    protected
    def self.reset
      # class leve laccess
      @@nb_player = 0
      TicTacToe::Shared::GameParms.poss_type =
        TicTacToe::Shared::GameParms.valid_played_sym.inject({}) {|h, v| h.merge({v.to_sym => 0})}
    end
    
  end # Player

  class PlayerIA < Player

    #
    # Return a valid move in the rnage [1...9]
    #
    def get_move(board)
      # TODO implement 
    end
    
  end
end
