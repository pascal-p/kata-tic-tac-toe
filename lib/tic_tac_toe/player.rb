require_relative './shared/game_parms'


module TicTacToe

  module MyFixnum
    extend self

    def _calc
      machine_bytes = ['foo'].pack('p').size
      8 * machine_bytes # == machine_bits
    end

    SIGNED_MAX = 2 ** (_calc - 2) - 1 # SIGNED_MAX(Fixnum), SIGNED_MAX + 1(Bignum)
    SIGNED_MIN = -SIGNED_MAX - 1

    # UNSIGNED_MAX = 2 ** (_calc - 1) - 1   # => Bignum
    # UNSIGNED_MIN = -UNSIGNED_MAX - 1      # => Bignum

    def const_missing(const_name)
      if const_name =~ /^MAX$|^MIN$/
        STDOUT.print("WARNING did you mean SIGNED_#{const_name}?\n")
        self.const_get "SIGNED_#{const_name}"
      else
        raise NameError, "uninitialized constant #{self}::#{const_name}"
      end
    end
  end

  class Player

    @@nb_player = 0
    @@game_parms = TicTacToe::Shared::GameParms.setup()

    attr_reader :name, :type

    def initialize(input)
      _nb_play = @@game_parms::MAX_PLAYER
      raise ArgumentError,
            "no more than #{_nb_play} allowed" if @@nb_player >= _nb_play
      raise ArgumentError,
            "input hash must not empty" if input == {} || !input.is_a?(Hash)
      #
      @name  = input.fetch(:name) { "foo_#{rand(100)}" }
      @type  = input.fetch(:type) { @@game_parms.poss_type.collect {|k, v| k if v == 0} }
      @board = input[:board]      # actually the grid portion of the board
      @@game_parms.poss_type[@type] = 1
      @@nb_player += 1           # ex. init { X: 0, O: 0 }, select O => { X: 0, O: 1 }
      #                          # so next player type will be X
    end

    def set_board(board)
      @board = board
    end

    def self.reset
      # class level access
      @@nb_player = 0
      @@game_parms.poss_type =
        @@game_parms.valid_played_sym.inject({}) {|h, v| h.merge({v.to_s.to_sym => 0})}
    end

    def is_IA_S?   # is IA with Strategy
      false
    end

    #
    # self.singleton_methods       ===> [:reset]
    #
    # self.instance_methods(false) ===> [:name, :type]
    #

    if $VERBOSE
      puts "[#{self}] ==> singleton (or class) methods: #{self.singleton_methods}"
      puts "[#{self}] ==> instance methods: #{self.instance_methods(false)}"
    end

  end # Player

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
  class IAPlayerRB < Player

    def initialize(input)
      super(input)
      # @fn_eval
    end

    def is_IA_S?
      true
    end

    def get_move
      raise "Abstract Method"
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

  end # PlayerIA_R

  # Simpleton strategy
  class IAPlayerS < Player

    def initialize(input)
      super(input)
      n = @@game_parms::DIM
      @dim = n * n
      @move_center = [ (@dim / 2.0).ceil ]
      @move_corner = [ 1,  n, @dim - n + 1, @dim]
      @move_side   = @@game_parms::POS.select { |x| !@move_center.include?(x) &&
                                                !@move_corner.include?(x) }
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
      move, x, y  = @move_center.first, @board.to_coord(move)
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

  end # PlayerIA

  #
  #
  #
  class IAPlayerMiniMax < Player

    attr_reader :oplayer

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
      _, move = minimax(2, self)
      return move # @board.to_move(x, y)
    end

    private
    # returns [score, move]
    def minimax(depth, cplayer)
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
          best_score, best_move =
                      if cplayer == self
                        try_move(depth, @oplayer, :>, move, best_score, best_move)
                      else
                        # oplayer's turn
                        try_move(depth, self, :<, move, best_score, best_move)
                      end
          @board.set_cell!(move.to_i, move.to_s) # reset this (tried) move
        end # all moves reviewed
      end
      [best_score, best_move]
    end

    def try_move(depth, player, rel, move, best_score, best_move)
      curr_score, _ = minimax(depth - 1, player)
      #
      if curr_score.send(rel, best_score)
        best_score = curr_score
        best_move = move
      end
      [best_score, best_move]
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

  end # of IAPlayerMinimax


  # TODO
  class IAPlayerAlphaBeta < Player

    def set_other!(player)
      @oplayer = player
    end

    def is_IA_S?
      true
    end

  end

  class HPlayer < Player

    def get_move
      m = -1
      loop do
        STDOUT.print ">> player: #{@name} #{@type} move in #{@@game_parms::POS.inspect}? "
        m = STDIN.gets.chomp.to_i
        break if m.to_i > 0 && m.to_i <= @@game_parms::DIM * @@game_parms::DIM
        STDOUT.print ">> ! illegal input - valid input is a digit in #{@@game_parms::POS.inspect}\n"
      end
      m
    end

  end

end
