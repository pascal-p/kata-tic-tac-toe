require_relative '../shared/game_parms'
require_relative '../base/player'
require_relative '../my_fixnum'

module TicTacToe

  module IA
    #
    #
    #
    class PlayerMiniMax < Base::Player
      
      attr_reader :oplayer
      
      Parms = Struct.new(:player, :depth, :rel, :best_score, :move, :best_move) do
        def rest
          nil
        end
      end

      def initialize(input) # , eval_fun = ->() {})
        super(input)
        @oplayer = input.fetch(:oplayer) { nil }
        # @eval_fun = eval_fun
      end

      def set_other!(player)
        @oplayer = player
      end

      def is_IA_S?
        true
      end

      def get_move
        _, move = search(@@game_parms::DIM - 1, self)
        return move # @board.to_move(x, y)
      end

      private
      # search - apply minimax search based strategy
      # \ returns [score, move]
      def search(depth, cplayer)
        next_moves = gen_moves()
        best_score = (cplayer == self) ? MyFixnum::SIGNED_MIN : MyFixnum::SIGNED_MAX
        best_move  = -1;
        #
        if next_moves.size == 0 || depth == 0
          best_score = eval_fun() # @eval_fun.call
        else
          next_moves.each do |move|
            @board.set_cell(move, cplayer.type) # try this move for cplayer
            # Who's turn?
            score_move = [ best_score, move, best_move ]
            best_score, best_move =
                        if cplayer == self
                          parms = Parms.new(@oplayer, depth, :>, *score_move)
                          try_move(parms)
                        else
                          # oplayer's turn
                          parms = Parms.new(self, depth, :<, *score_move)
                          try_move(parms)
                        end
            @board.set_cell!(move.to_i, move.to_s) # reset this (tried) move
          end # all moves reviewed
        end
        [best_score, best_move]
      end

      def try_move(parms)
        curr_score, _ = search(parms.depth - 1, parms.player, *parms.rest)
        #
        if curr_score.send(parms.rel, parms.best_score)
          parms.best_score = curr_score
          parms.best_move = parms.move
        end
        [parms.best_score, parms.best_move]
      end

      def gen_moves
        @board.inject([]) {|a, cell| cell.empty? ? a << cell.val : a}
      end

      def eval_fun() # @board, self (== cplayer), oplayer
        score = 0
        [:each_col, :each_row, :each_diag].each do |meth|
          #
          @board.send(meth.to_sym) do |obj_coll|
            score += obj_coll.inject(0) {|s, cell| s = _score(cell, s)}
          end
        end
        score
      end

      def _score(cell, score)
        @store ||= []
        #
        if @store.size == 0
          score = first_(cell, score)
          @store << cell
          return score
        end
        #
        if @store.size == 1
          score = second_(cell, score)
          @store << cell
          return score
        end
        #
        if @store.size == 2
          score = third_(cell, score)
          @store = []
        end
        score
      end

      def first_(cell, score=0)
        if cell.val.to_s == self.type.to_s
          1
        elsif cell.val.to_s == @oplayer.type.to_s
          -1
        else
          score
        end
      end

      def second_(cell, score)
        m = if cell.val.to_s == self.type.to_s
              1
            elsif cell.val.to_s == @oplayer.type.to_s
              -1
            end
        return score if m.nil?
        #
        case score
        when 1 * m
          10 * m
        when -1 * m
          0
        else
          1 * m
        end
      end

      def third_(cell, score)
        rels, m =
              if cell.val.to_s == self.type.to_s
                [[:>, :<], 1]
              elsif cell.val.to_s == @oplayer.type.to_s
                [[:<, :>], -1]
              end
        #
        return score if rels.nil?
        #
        if score.send(rels.first, 0)   # < or >
          score * 10
        elsif score.send(rels.last, 0) # > or <
          0
        else
          1 * m
        end
      end

    end
    
  end

end
