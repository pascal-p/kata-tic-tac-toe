require_relative './shared/game_parms'

module TicTacToe

  class Player

    @@nb_player = 0
    @@game_parms = TicTacToe::Shared::GameParms.setup()

    attr_reader :name, :type

    def initialize(input)
      _nb_play = @@game_parms::MAX_PLAYER
      raise ArgumentError,
            "no more than #{_nb_play} allowed" if @@nb_player >= _nb_play
      raise ArgumentError,
            "input hash should be defined and not empty" if input == {} || !input.is_a?(Hash)
      #
      @name = input.fetch(:name) { "foo_#{rand(100)}" }
      @type = input.fetch(:type) { @@game_parms.poss_type.collect {|k, v| k if v == 0} }
      @@game_parms.poss_type[@type] = 1
      @@nb_player += 1           # ex. init { X: 0, O: 0 }, select O => { X: 0, O: 1 }
      #                          # so next player type will be X
    end

    def self.reset
      # class level access
      @@nb_player = 0
      @@game_parms.poss_type =
        @@game_parms.valid_played_sym.inject({}) {|h, v| h.merge({v.to_s.to_sym => 0})}
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

  # rule based
  class IAPlayerRB < Player
    
    def initialize(input)
      super(input)
      # @fn_eval
    end

    def get_move(board)
      raise "Abstract Method"
    end

    private
    #
    # Helper for rule 1 & rule 2
    #
    # Returns a list of rows(Ary), cols(Ary), diag(Ary) in that order were 2 symbols are already in
    # place if no 2 symbols, returns [[], [], []]
    def _2_in_the_board(board, type=self.type)
      # check cols
      hcols = _traversal(board.cols, type, :c)
      ary =
        if hcols.size == 0
          # check lines/rows
          hrows = _traversal(board.rows, type, :r)
          if hrows.size == 0
            # check diags
            hdiags = _traversal(board.diags, type, :d)
            if hdiags.size > 0
              # play first available diag from hdiags
              hdiags.first # == Array e.g. [:d2, 2]  # will always be 2 if defined (by construction)
            else
              # NO-OP
              []
            end
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

    #
    # Return a valid move in the range [1..9]
    #
    def get_move(board)
      STDOUT.print("\tPlayer #{self.name}/#{self.type} -- " +
                   "center: #{@move_center.inspect} // corner: #{@move_corner.inspect} " +
                   "// side: #{@move_side.inspect}\n") if $VERBOSE
      # play center
      if rand(2) > 0 && !@move_center.empty? # plus some randomness for IA vs IA
        #                                      maybe a problem - if it the only valid move!
        m = _play_center(board)
        return m if m > 0
      end
      # play opposite corner
      if !@move_corner.empty?
        m = _find_free_opp_corner(board)
        STDOUT.print "\tPlayer #{self.name}/#{self.type} trying corner...#{m}\n" if $VERBOSE
        return m if m > 0
      end
      # play opposite side
      if !@move_side.empty?
        m = _find_free_side(board)
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
      @first_time = false
      ix = rand(@move_corner.size)
      move = @move_corner[ix]
      @move_corner.delete_at(ix)
      return move
    end

    def _play_center(board)
      move = @move_center.first
      x, y = board.grid.to_coord(move)
      move = 0 unless board.grid.get_cell(x, y).empty?
      @move_center = []
      return move
    end

    def _find_free_opp_corner(board)
      _move_hlpr(board, @move_corner)
    end

    def _find_free_side(board)
      _move_hlpr(board, @move_side)
    end

    def _move_hlpr(board, ary)
      move = 0
      poss = []
      ary.each_with_index do |m, ix|
        STDOUT.print("\t===> trying m: #{m.inspect} // ix: #{ix} // limit: #{(ary.size / 2.0).ceil}\n") if $VERBOSE
        break if ix >= (ary.size / 2.0).ceil  # symetry - but when ary size is 1,
        #                                     # make sure we check the last cell
        opp_m = @dim + 1 - m # opposite corner
        x, y   = board.grid.to_coord(m)
        xp, yp = board.grid.to_coord(opp_m)
        if board.grid.get_cell(x, y).empty?
          # cell(x, y) FREE - check the opposite corner
          if !board.grid.get_cell(xp, yp).empty?
            move = m # cell(x, y) FREE && cell(xp, yp) == opp_m TAKEN
            break
          else
            # cell(x, y) FREE && cell(xp, yp) FREE
            poss.concat([m, opp_m]) # poss << m
          end
        elsif board.grid.get_cell(xp, yp).empty?
          #  cell(x, y) TAKEN  && cell(xp, yp) FREE
          move = opp_m
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

  class IAPlayerMinMax < Player
    
  end

  
  class IAPlayerAlphaBeta < Player
    
  end    

  
  class HPlayer < Player
    
    def get_move(board)
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
