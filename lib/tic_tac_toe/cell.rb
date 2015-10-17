require_relative './shared/game_cst'

module TicTacToe

  class Cell
    include Comparable
    attr_reader :val

    def initialize(val='')
      @game_cst = TicTacToe::Shared::GameCst.setup()
      @val = @game_cst.all_sym.include?(val) ? val :
               @game_cst::NONE
    end

    def <=>(oth)
      self.val <=> oth.val
    end

    #
    # Set the val to @val iff previous val was TicTacToe::Shared::GameCst::NONE
    # Returns TicTacToe::Shared::GameCst::NONE otherwise
    #
    def set_val(val)
      return @game_cst::NONE if !@game_cst.all_sym.include?(val)
      if @val.to_s == @game_cst::NONE
        @val = val
      else
        @game_cst::NONE
      end
    end

    #
    # Set the val to @val unconditionnaly
    # Returns TicTacToe::Shared::GameCst::NONE if val is not a legal value
    #
    def set_val!(val)
      return @game_cst::NONE if !@game_cst.all_sym.include?(val)
      @val = val 
    end

    alias_method :val=, :set_val!

  end

end
