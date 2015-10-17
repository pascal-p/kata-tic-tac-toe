
module TicTacToe
  
  module Shared

    module GameCst
      extend self

      DIM = 3
      NONE = '_'
      O = 'O'
      X = 'X'
      
      @all_sym = [ NONE, O, X ]
      @valid_played_sym =  @all_sym.slice(1, @all_sym.length - 1)
      
      attr_reader :all_sym, :valid_played_sym

      def setup
        self
      end
    end
    
  end # Shared

end # TicTacToe
