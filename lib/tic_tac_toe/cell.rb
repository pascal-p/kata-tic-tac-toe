require_relative './shared/game_parms'

module TicTacToe

  class Cell
    include Comparable
    attr_reader :val

    def initialize(val='')
      @game_parms = TicTacToe::Shared::GameParms.setup()
      @val = @game_parms.all_sym.include?(val) ? val :
               @game_parms::NONE
    end

    def <=>(oth)
      self.val <=> oth.val
    end

    def empty?
      !@game_parms.valid_played_sym.include?(@val)
    end
    
    #
    # Set the val to @val iff previous val was TicTacToe::Shared::GameParms::NONE
    # Returns TicTacToe::Shared::GameParms::NONE otherwise
    #
    def set_val(val)
      return @game_parms::NONE if !@game_parms.all_sym.include?(val)
      if ! @game_parms.valid_played_sym.include?(@val)
        # set the value if current value (@val) is not in the @game_parms.valid_played_sym array
        @val = val
      else
        @game_parms::NONE
      end
    end

    #
    # Set the val to @val unconditionnaly
    # Returns TicTacToe::Shared::GameParms::NONE if val is not a legal value
    #
    def set_val!(val)
      return @game_parms::NONE if !@game_parms.all_sym.include?(val)
      @val = val 
    end

    alias_method :val=, :set_val!

  end

end
