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
      @content = klass.kind_of?(Array) ?
                   _init(klass) :
                   Array.new(@game_parms::DIM).map {Array.new(@game_parms::DIM) { klass.new }}
      self
    end

    def nb_cols
      @game_parms::DIM
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
      (0...@game_parms::DIM).to_a.inject([]) {|ca, il| ca << @content[il][ic]}
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
      (0...@game_parms::DIM).to_a.inject([]) {|ca, ix| ca << @content[ix][@game_parms::DIM - 1 - ix]}
    end

    #
    # [ [ '_', '', '' ]
    #   [ '', '_', '' ]
    #   [ '', '', '_' ] ]
    #
    def diag_down
      (0...@game_parms::DIM).to_a.inject([]) {|ca, ix| ca << @content[ix][ix]}
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
      if m <= @game_parms::DIM
        [ 0, m - 1 ]
      elsif  m <= 2 * @game_parms::DIM
        [ 1, m - @game_parms::DIM - 1 ]
      else
        [ 2, m - 2 * @game_parms::DIM - 1 ]
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
      x * @game_parms::DIM + y + 1
    end

    def each
      (0...@game_parms::DIM).each do |ix|
        (0...@game_parms::DIM).each do |jx|
          yield
        end
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
      define_method(m) do
        (0...@game_parms::DIM).to_a.inject([]) {|a, ix| a << self.send(accessor, ix)}
      end

      define_method(meth) do
        (0...@game_parms::DIM).to_a.any? do |ix|
          self.send(accessor, ix).all? {|c| c.val == @game_parms::O} ||
            self.send(accessor, ix).all? {|c| c.val == @game_parms::X}
        end
      end
    end

    #
    # set the cell unconditionnaly - but check for th validity of the val
    #
    def set_cell!(il, ic, val)
      @content[il][ic].val= val # delegate to cell
    end

    #
    # ignore args.size > 3
    #
    def set_cell(*args)
      il, ic = args[0..1] # ic may be a string
      if ic.is_a?(String)
        # il is a m (move) which needs to be converted, ic is the val
        jl, jc = *to_coord(il)
        @content[jl][jc].set_val(ic)
      elsif args.size > 2
        @content[il][ic].set_val(args[2])
      else
        # NO-OP
      end
    end

    def to_s
      (0...@game_parms::DIM).to_a.inject("") do |s, ix|
        s << " " << @content[ix].map {|c| c.val }.join(' | ') << "\n" <<
          "---|---|---\n"
      end
    end

    def to_a
      (0...@game_parms::DIM).inject([]) do |_a, il|
        _a.concat((0...@game_parms::DIM).inject([]) {|_na, ic| _na << @content[il][ic].val })
      end
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
        (0...@game_parms::DIM).inject([]) do |_a, il|
          _a << (0...@game_parms::DIM).inject([]) {|_na, ic| _na << TicTacToe::Cell.new(ary[il][ic]) }
        end
      else
        # single array
        a = ary.flat_map {|_a| _a}
        (0...@game_parms::DIM).inject([]) do |_a, il|
          _a << (0...@game_parms::DIM).inject([]) {|_na, ic| _na << TicTacToe::Cell.new(a[ic + 3*il]) }
        end
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
    def_delegators :@grid, :diags, :cols, :col, :rows, :row, :lines, :line, :each, :[],
       :nb_cols, :nb_rows, :nb_lines
    def_delegators :@grid, :set_cell, :get_cell, :to_s, :to_a, :to_coord, :empty?

    # STDERR.puts("=[#{self}] my instance methods: #{self.instance_methods(false)}")

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
    [:diags_win_case?,
     :cols_win_case?,
     :lines_win_case? ].each do |meth|
      define_method(meth) do
        @grid.send(meth)
      end
    end

  end

end
