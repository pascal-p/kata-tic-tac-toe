require_relative '../shared/game_parms'
require_relative './player_minimax'
require_relative '../my_fixnum'

module TicTacToe

  module IA

    class PlayerAlphaBeta < IA::PlayerMiniMax

      Parms = Struct.new(:player, :depth, :rel, :best_score, :alpha, :beta, :move, :best_move) do
        def rest
          [self.alpha, self.beta]
        end
      end

      def get_move
        _, move = search(@@game_parms::DIM - 1, self, MyFixnum::SIGNED_MIN, MyFixnum::SIGNED_MAX)
        return move # @board.to_move(x, y)
      end

      private
      # search - apply alpha-beta pruning search based strategy
      # \ returns [score, move]
      def search(depth, cplayer, alpha, beta)
        next_moves = gen_moves()
        best_move  = -1;
        if next_moves.size == 0 || depth == 0
          score = eval_fun() # @eval_fun.call
          return [score, best_move]
        else
          next_moves.each do |move|
            @board.set_cell(move, cplayer.type) # try this move for cplayer
            score_move = [ alpha, beta, move, best_move ]
            if cplayer == self
              parms = Parms.new(@oplayer, depth, :>, alpha, *score_move)
              alpha, best_move = try_move(parms)
            else
              # oplayer's turn
              parms = Parms.new(@oplayer, depth, :<, beta, *score_move)
              beta, best_move = try_move(parms)
            end
            @board.set_cell!(move.to_i, move.to_s) # reset this (tried) move
            break if alpha >= beta
          end
          return [cplayer == self ?  alpha : beta, best_move]
        end
      end

    end # of IAPlayerAlphaBeta
    
  end

end
