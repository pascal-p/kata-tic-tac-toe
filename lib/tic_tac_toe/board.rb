require 'forwardable'
require_relative './shared/game_parms'

module TicTacToe

  module Grid
    include Enumerable
    extend self

    #
    def setup(klass=TicTacToe::Cell)
      # is is an Array literal (assuming correct dim) or a Cell
      @game_parms = TicTacToe::Shared::GameParms.setup()
      @dim = @game_parms::DIM
      @content = klass.kind_of?(Array) ?
                   _init(klass) :
                   Array.new(@dim).map {Array.new(@dim) { klass.new }}
      self
    end

    def nb_cols
      @dim
    end

    alias_method :nb_lines, :nb_cols

    #
    # Returns a set of Cell objects
    #
    def line(il)
      @content[il]
    end

    #
    # Returns a set of Cell objects
    #
    def col(ic)
      (0...@dim).to_a.inject([]) {|ca, il| ca << @content[il][ic]}
    end

    #
    # Returns a Cell object value
    #
    def [](il, ic)
      @content[il][ic].val
    end

    #
    # [ [ '', '', '_' ]
    #   [ '', '_', '' ]
    #   [ '_', '', '' ] ]
    #
    def diag_up
      (0...@dim).to_a.inject([]) {|ca, ix| ca << @content[ix][@dim - 1 - ix]}
    end

    #
    # [ [ '_', '', '' ]
    #   [ '', '_', '' ]
    #   [ '', '', '_' ] ]
    #
    def diag_down
      (0...@dim).to_a.inject([]) {|ca, ix| ca << @content[ix][ix]}
    end

    def diags
      [ diag_up, diag_down ]
    end

    #
    # [ [ 1=(0,0) 2=(0,1) 3=(0,2) ]
    #   [ 4=(1,0) 5=(1,1) 6=(1,2) ]
    #   [ 7=(2,0) 8=(2,1) 9=(2,2) ] ]
    #
    def to_coord(m)
      if m <= @dim
        [ 0, m - 1 ]
      elsif  m <= 2 * @dim
        [ 1, m - @dim - 1 ]
      else
        [ 2, m - 2 * @dim - 1 ]
      end
    end

    #
    # (0, 0) == 1
    # (0, 1) == 2
    # ...
    # (1, 1) == 5
    # ...
    # (2, 2) == 9
    def to_move(x, y)
      x * @dim + y + 1
    end

    def each
      (0...@dim).each do |ix|
        (0...@dim).each {|jx| yield @content[ix][jx]}
      end
    end

    def diags_win_case?
      diags.any? do |diag|
        diag.all? {|c| c.val == @game_parms::O} ||
          diag.all? {|c| c.val == @game_parms::X}
      end
    end

    [:lines, :cols].each do |m|
      meth = "#{m}_win_case?".to_sym
      accessor = m.to_s.sub(/s$/, '').to_sym
      #
      # define lines() and cols() methods
      define_method(m) do
        (0...@dim).to_a.inject([]) {|a, ix| a << self.send(accessor, ix)}
      end
      #
      # define lines_win_case?, cols_win_case? predicates (methods)
      define_method(meth) do
        (0...@dim).to_a.any? do |ix|
          self.send(accessor, ix).all? {|c| c.val == @game_parms::O} ||
            self.send(accessor, ix).all? {|c| c.val == @game_parms::X}
        end
      end
    end

    [:cols, :rows, :diags].each do |coll|
      singular = coll.to_s.sub(/s$/, '')
      #
      # define each_col(), each_row(), each_diag() methods
      define_method("each_#{singular}".to_sym) do |&blk|
        self.send(coll).each {|obj| blk.call obj }
      end
    end

    #
    # set the cell unconditionnaly - but check for the validity of the val
    #
    def set_cell!(*args)   # NEED TOCHECK WHAT IS HAPPENING WITH set_val
      _set_cell_hplr(args, :set_val!)
    end

    #
    # ignore args.size > 3
    #
    def set_cell(*args)
      _set_cell_hplr(args, :set_val)
    end

    def _set_cell_hplr(args, setter)
      ix, iy = args[0..1] # iy may be a string
      #
      if iy.is_a?(String) || iy.is_a?(Symbol)
        # ix is a m (move) which needs to be converted, iy is the val
        jx, jy = *to_coord(ix.to_i)
        @content[jx][jy].send(setter, iy.to_s)
        #
      elsif args.size > 2
        @content[ix][iy].send(setter, args[2].to_s)
        #
      else
        # NO-OP
      end
    end

    def to_s
      (0...@dim).to_a.inject("") do |s, ix|
        s << " " << @content[ix].map {|c| c.val }.join(' | ') << "\n" <<
          "---|---|---\n"
      end
    end

    def to_a
      (0...@dim).inject([]) do |_a, il|
        _a.concat((0...@dim).inject([]) {|_na, ic| _na << @content[il][ic].val })
      end
    end

    def inspect
      "#{self.class}: <@dim: #{@dim}, @content: #{@content.inspect}>"
    end

    #
    # Returns true when the grid is complete (with valid token)
    #
    def filled?
      self.to_a.all? {|v| @game_parms.valid_played_sym.include?(v) }
    end

    #
    # Returns true if none of the cell is set to 'O' or 'X'
    #
    def empty?
      self.to_a.all? {|v| !@game_parms.valid_played_sym.include?(v)}
    end
    #
    # all _row_ methods can be renamed as _line_ methods for convenience
    # also handle get|set_cell
    #
    def method_missing(meth, *args, &block)
      meth_s = meth.to_s
      if meth_s =~ /^(row).+$/ || meth_s =~ /^nb_(row).*$/
        super if $1.to_s.length == 0
        rmeth = _meth_builder($1, meth_s)
        self.send(rmeth, *args, &block)
      elsif meth_s =~ /^get_cell$/
        x, y = args[0..1]
        # puts "....> x: #{x.inspect}, y: #{y.inspect}"
        x, y = to_coord(x) if y.nil? # it is a move and only x is defined, get the coordinates
        # puts "......> x: #{x.inspect}, y: #{y.inspect}"
        raise ArgumentError,
              "cell coordinates not defined x:#{x.inspect}, y: #{y.inspect}" if x.nil? && y.nil?
        @content[x][y]
      else
        STDERR.puts("Do not know this method: #{meth} called on #{self.inspect} !!!")
        super
      end
    end

    def respond_to_missing?(meth, include_private=false)
      meth_s = meth.to_s
      if meth_s =~ /^(row).+$/ || meth_s =~ /^nb_(row).*$/
        super if $1.to_s.length == 0
        rmeth = _meth_builder($1, meth_s)
        self.class.instance_methods(false).include?(rmeth)
      elsif meth_s =~ /^get_cell$/
        #elsif meth_s =~ /^[sg]et_cell$|^set_cell!$/
        true
      else
        super
      end
    end

    #
    # STDERR.puts("=[#{self.inspect}]=> my instance methods are: #{self.instance_methods(false)}")
    #

    private
    # 2 cases: array of array  [[...], [...], [...]] or single array [... ... ...]
    #
    def _init(ary)
      if ary.first.is_a?(Array)
        (0...@dim).inject([]) do |_a, il|
          _a << (0...@dim).inject([]) {|_na, ic| _na << TicTacToe::Cell.new(ary[il][ic]) }
        end
      else
        # single array
        a = ary.flat_map {|_a| _a}

        ary = (0...@dim).inject([]) do |_a, il|
          _a << (0...@dim).inject([]) {|_na, ic| _na << TicTacToe::Cell.new(a[ic + @dim * il]) }
        end
        # puts "===> [#{__method__} / DEBUG] ary: #{ary.inspect}\n"
        ary
      end
    end

    def _meth_builder(token, meth)
      old = token.to_s
      meth.to_s.sub(/#{old}/, 'line').to_sym # first match
    end

  end


  class Board
    extend Forwardable

    attr_accessor :grid

    def initialize(grid=TicTacToe::Grid.setup(TicTacToe::Shared::GameParms::POS))
      @grid = grid.kind_of?(Array) ? TicTacToe::Grid.setup(grid) : grid
      @winner_called = 0
      @draw_called = 0
    end

    def game_over?
      return :winner if winner?
      return :draw if draw?
      false
    end

    # delegation
    def_delegators :@grid, :diags, :cols, :col, :rows, :row, :lines, :line, :each, :[], :nb_cols,
       :nb_rows, :nb_lines
    def_delegators :@grid, :set_cell, :set_cell!, :get_cell, :to_s, :to_a, :to_coord, :empty?

    private
    #
    # all cells (or all but one) filled (and no 3 same symbols)
    # for no 3 'aligned' symbols => call winner? but only if it was not called
    #
    def draw?
      diff = (@winner_called - @draw_called).abs
      @draw_called += 1
      unless diff == 1
        flag = winner?
        return !flag if flag # winner? => not draw?
      end
      # @grid.filled_but_one? || @grid.filled?
      @grid.filled?
    end

    def winner?
      @winner_called += 1
      diags_win_case? ||
        cols_win_case? ||
        lines_win_case?
    end

    #
    # Returns true if any of the 2 diags contain the smae symbol
    # Returns true if any of the 3 columns contain the smae symbol
    # Returns true if any of the 3 line contain the smae symbol
    #
    [:diags_win_case?, :cols_win_case?, :lines_win_case? ].each do |meth|
      #
      #
      define_method(meth) do
        @grid.send(meth)
      end
    end

  end

end
