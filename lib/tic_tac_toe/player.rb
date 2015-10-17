require_relative './shared/game_cst'

module TicTacToe

  class Player

    attr_reader :name, :type

    @@poss_type  = { TicTacToe::Shared::GameCst::X.to_s.downcase.to_sym => 0,
                     TicTacToe::Shared::GameCst::O.to_s.downcase.to_sym => 0 }
    @@max_num_player = 2
    @@num_player     = 0
    
    def initialize(input)
      raise ArgumentError,
            "no more than #{@@max_num_player} allowed" if @@num_player >= @@max_num_player
      raise ArgumentError,
            "input hash should be defines and not empty" if input == {} || !input.is_a?(Hash)
      #
      @name = input.fetch(:name) { "foo_#{rand(100)}" }
      @type = input.fetch(:type) { @@poss_type.collect {|k, v| k if v == 0} }
      @@poss_type[@type] = 1
      @@num_player += 1
    end

    private
    def self.reset
      @@num_player = 0
      @@poss_type  = { TicTacToe::Shared::GameCst::X.to_s.downcase.to_sym => 0,
                       TicTacToe::Shared::GameCst::O.to_s.downcase.to_sym => 0 }
    end
    
  end
  
end
