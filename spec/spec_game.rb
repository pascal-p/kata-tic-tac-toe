# spec/spec_game.rb
require 'spec_helper'

module TicTacToe

  describe Game do
    before(:example) do
      board = TicTacToe::Board.new()
      @p1 = Player.new(name: 'foo', type: TicTacToe::Shared::GameCst::O)
      @p2 = Player.new(name: 'bar', type: TicTacToe::Shared::GameCst::X)      
      @game = Game.new(board, @p1, @p2)      
      @game_const = TicTacToe::Shared::GameCst.setup
    end

    after(:example) do
        Player.send(:reset)
    end
    
    context "#player" do

      it "initialize player turns - randomly" do
        actual = @game.send(:_init_players)
        expected = [@p1, @p2]
        expect(actual).to contain_exactly(*expected)
      end

      it "alternate the game between the two players" do
        actual1 = @game.send(:_switch_players, @p1, @p2)  # if p1, p2...
        actual2 = @game.send(:_switch_players, @p2, @p1)
        #
        expect(actual1).to match_array([@p2, @p1])        # then p2, p1
        expect(actual2).to match_array([@p1, @p2])
      end
      
    end
    
  end
  
end
