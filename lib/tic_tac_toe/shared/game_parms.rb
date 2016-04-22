module TicTacToe

  module Shared

    module GameParms
      extend self

      DIM        = 5       # or 5
      NONE       = '_'
      O          = 'O'
      X          = 'X'
      MAX_PLAYER = 2
      POS        = (1..DIM * DIM).to_a

      @all_sym = [ NONE, O, X ] + POS.map(&:to_s)

      @valid_played_sym = @all_sym.slice(1, 2)
      # \ == ['O', 'X', '1', '2', '3', '4', '5', '6', '7', '8', '9']

      @poss_type = @valid_played_sym.inject({}) {|h, v| h.merge({v.to_s.to_sym => 0})}
      #          == { X: 0, O: 0, '1': 0 ... '9': 0}  # initialization

      attr_reader   :all_sym, :valid_played_sym
      attr_accessor :poss_type

      def setup
        self
      end

    end

  end # Shared

end # TicTacToe
