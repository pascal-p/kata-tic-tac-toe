require_relative '../shared/game_parms'
require_relative '../base/player'

module TicTacToe

  module IA
    
    # Simpleton strategy
    class PlayerS < Base::Player

      def initialize(input)
        super(input)
        n = @@game_parms::DIM
        @dim = n * n
        @move_center = [ (@dim / 2.0).ceil ]
        @move_corner = [ 1,  n, @dim - n + 1, @dim]
        @move_side   = @@game_parms::POS.reject { |x| @move_center.include?(x) ||                                                @move_corner.include?(x)}
      end

      # inherits is_IA_S?

      #
      # Return a valid move in the range [1..9]
      #
      def get_move
        STDOUT.print("\tPlayer #{self.name}/#{self.type} -- " +
                     "center: #{@move_center.inspect} // corner: #{@move_corner.inspect}" +
                     " // side: #{@move_side.inspect}\n") if $VERBOSE
        # play center
        if rand(2) > 0 && !@move_center.empty? # plus some randomness for IA vs IA
          #                                      maybe a problem - if it the only valid move!
          m = _play_center
          return m if m > 0
        end
        # play opposite corner
        if !@move_corner.empty?
          m = _find_free_opp_corner
          STDOUT.print "\tPlayer #{self.name}/#{self.type} trying corner...#{m}\n" if $VERBOSE
          return m if m > 0
        end
        # play opposite side
        if !@move_side.empty?
          m = _find_free_side
          STDOUT.print "\tPlayer #{self.name}/#{self.type} trying side...#{m}\n" if $VERBOSE
          return m if m > 0
        end
        raise ArgumentError,
              "No more move to play for #{self.name} / #{self.type} /\n" +
              "center: #{@move_center.inspect} // corner: #{@move_corner.inspect} // side: #{@move_side.inspect}"
      end

      private
      #
      # side effect on @move_corner
      #
      def _first_move          # play any any corner (these are free by definition)
        @first_time, ix = false, rand(@move_corner.size)
        move = @move_corner[ix]
        @move_corner.delete_at(ix)
        return move
      end

      def _play_center
        move = @move_center.first
        x, y = @board.to_coord(move)
        move = 0 unless @board.get_cell(x, y).empty?
        @move_center = []
        return move
      end

      def _find_free_opp_corner
        _move_hlpr(@move_corner)
      end

      def _find_free_side
        _move_hlpr(@move_side)
      end

      def _move_hlpr(ary)
        move = 0
        poss = []
        ary.each_with_index do |m, ix|
          STDOUT.print("\t==> trying m: #{m.inspect} // ix: #{ix} // limit: #{(ary.size / 2.0).ceil}\n") if $VERBOSE
          break if ix >= (ary.size / 2.0).ceil  # symetry - but when ary size is 1,
          #                                     # make sure we check the last cell
          opp_m  = @dim + 1 - m # opposite corner
          x, y   = @board.to_coord(m)
          xp, yp = @board.to_coord(opp_m)
          if @board.get_cell(x, y).empty?
            # cell(x, y) FREE - check the opposite corner
            if !@board.get_cell(xp, yp).empty?
              move = m # cell(x, y) FREE && cell(xp, yp) == opp_m TAKEN
              break
            else
              poss.concat([m, opp_m]) # cell(x, y) FREE && cell(xp, yp) FREE
            end
          elsif @board.get_cell(xp, yp).empty?
            move = opp_m #  cell(x, y) TAKEN  && cell(xp, yp) FREE
            break
          else
            # NO-OP everythin is taken
          end
        end
        STDOUT.print("\t===> move; #{move} // poss: #{poss.inspect}\n") if $VERBOSE
        # update
        if move > 0
          # remove ths pos. and its opposite if move > 0
          ary.delete(move)
          ary.delete(@dim + 1 - move)
        elsif !poss.empty?   # move == 0
          ix = rand(poss.size - 1)
          move = poss[ix]
          ary.delete(move)
        end
        move
      end

      if $VERBOSE
        puts "[#{self}] ==> singleton (or class) methods: #{self.singleton_methods}"
        puts "[#{self}] ==> instance methods: #{self.instance_methods(false)}"
      end

    end

  end

end
