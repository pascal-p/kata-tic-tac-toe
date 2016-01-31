require_relative './shared/game_parms'

module TicTacToe

  class Cell
    include Comparable
    attr_reader :val

    def initialize(val='')
      @gparms = TicTacToe::Shared::GameParms.setup()
      @val = @gparms.all_sym.include?(val.to_s) ? val.to_s : @gparms::NONE
    end

    def <=>(oth)
      self.val <=> oth.val
    end

    def empty?
      r = !@gparms.valid_played_sym.include?(@val)
      # puts "***** call empty? sym: #{@gparms.valid_played_sym.inspect} / val: #{@val.inspect} ==> #{r}"
      r
    end

    #
    # Set the val to @val iff previous val was TicTacToe::Shared::GameParms::NONE
    # Returns TicTacToe::Shared::GameParms::NONE otherwise
    #
    def set_val(val)
      return @gparms::NONE if !@gparms.all_sym.include?(val.to_s)

      if @gparms.valid_played_sym.include?(@val)
        # already and X or and O => do nothing!
        @gparms::NONE
      else
        @val = val.to_s
      end
    end

    #
    # Set the val to @val unconditionnaly
    # Returns TicTacToe::Shared::GameParms::NONE if val is not a legal value
    #
    def set_val!(val)
      return @gparms::NONE if !@gparms.all_sym.include?(val.to_s)
      @val = val.to_s
    end

    alias_method :val=, :set_val!

  end

end
