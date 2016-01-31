require_relative '../shared/game_parms'
require_relative '../base/player'

module TicTacToe

  module IA
    #
    # Rule Based - to implement
    # src: https://www3.ntu.edu.sg/home/ehchua/programming/java/JavaGame_TicTacToe_AI.html
    #
    # For Tic-tac-toe, the rules, in the order of importance, are:
    #
    #  R1: If I have a winning move, take it.
    #  R2: If the opponent has a winning move, block it.
    #  R3: If I can create a fork (two winning ways) after this move, do it.
    #  R4: Do not let the opponent creating a fork after my move.
    #     \ Opponent may block your winning move and create a fork.
    #  R5: Place in the position such as I may win in the most number of possible ways.
    #
    # Comments:
    # - R1 and R2 can be programmed easily.
    # - R3 is harder.
    # - R4 is even harder because you need to lookahead one opponent move, after your move.
    # - R5, you need to count the number of possible winning ways.
    #
    # Note: Rule-based strategy is only applicable for simple game such as Tic-tac-toe and Othello.
    #
    class PlayerRB < Base::Player
      
      def initialize(input)
        super(input)
        # @fn_eval
      end

      def is_IA_S?
        true
      end

      def get_move
        raise "Not yet implemeted"
      end

      private
      #
      # Helper for rule 1 & rule 2
      #
      # Returns a list of rows(Ary), cols(Ary), diag(Ary) in that order were 2 symbols are already in
      # place if no 2 symbols, returns [[], [], []]
      def _2_in_the_board(type=self.type)
        # check cols
        hcols = _traversal(@board.cols, type, :c)
        ary =
          if hcols.size == 0
            # check lines/rows
            hrows = _traversal(@board.rows, type, :r)
            if hrows.size == 0
              # check diags
              hdiags = _traversal(@board.diags, type, :d)
              hdiags.size > 0 ? hdiags.first : []
            else
              # play first available row from hrows
              hrows.first # == Array e.g. [:r1, 2]  # will always be 2 if defined (by construction)
            end
          else
            # play first available column from hcols
            hcols.first # == Array e.g. [:c1, 2]  # will always be 2 if defined (by construction)
          end
        return ary
      end

      def _traversal(coll, type, key=:c) # collection
        ix = 0
        coll.inject({}) do |h, l|
          ix += 1
          h.merge({"#{key}#{ix}".to_sym =>
                                 l.inject(0) {|cv, cell| cv += cell.val == type ? 1 : 0}})
        end.select {|_, v| v > 1}
      end

    end
    
  end

end

