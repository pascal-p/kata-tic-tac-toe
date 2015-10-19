
module TicTacToe
  
  module Shared

    module GameParms
      extend self

      DIM = 3
      NONE = '_'
      O = 'O'
      X = 'X'
      MAX_PLAYER = 2
      POS = (1..9).to_a
      
      @all_sym = [ NONE, O, X ] + POS

      @valid_played_sym =  @all_sym.slice(1, 2) # @all_sym.length - 1)

      @poss_type = @valid_played_sym.inject({}) {|h, v| h.merge({v.to_s.to_sym => 0})}  
      
      attr_reader :all_sym, :valid_played_sym
      attr_accessor :poss_type
      
      def setup
        self
      end

    end
    
  end # Shared

end # TicTacToe
