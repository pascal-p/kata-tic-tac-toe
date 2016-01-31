require 'spec_helper'

module TicTacToe

  describe Base::Player do

    before :example do
      @game_parms = TicTacToe::Shared::GameParms.setup
    end

    after(:example) do
      Base::Player.send(:reset)
    end

    context "#initialized" do

      it "raises an exception when empty hash is provided" do
        expect { Base::Player.new {} }.to raise_error(ArgumentError)
        expect { Base::Player.new [] }.to raise_error(ArgumentError)
        expect { Base::Player.new "" }.to raise_error(ArgumentError)
      end

      it "succeeds with a valid input" do
        input = { name: "John", type: @game_parms::X }
        player = Base::Player.new input
        expect(player.name).to eq input[:name]
        expect(player.type).to eq input[:type]
      end

      it "does not allow more than 2 players" do
        inp = [ { name: "John", type: @game_parms::X},
                { name: "James", type: @game_parms::O} ]
        p1 = Base::Player.new inp[0]
        p2 = Base::Player.new inp[1]
        [p1, p2].each_with_index do |p, ix|
          expect(p.name).to eq inp[ix][:name]
          expect(p.type).to eq inp[ix][:type]
        end
        #
        expect { Base::Player.new inp[0] }.to raise_error(ArgumentError)
      end

    end

  end

  describe IA::PlayerRB do

    before :example do
      @game_parms = TicTacToe::Shared::GameParms.setup
      inp = { name: "James", type: @game_parms::O}
      @ia = IA::PlayerRB.new inp
    end

    after(:example) do
      Base::Player.send(:reset)
    end

    context "#2 seeds on a row, col, diag for me" do

      it "returns the col with 2 seeds of player's type" do
        board = Board.new([ [@game_parms::NONE, @game_parms::NONE, @game_parms::X],
                            [@game_parms::X, @game_parms::NONE, @game_parms::O],
                            [@game_parms::NONE, @game_parms::NONE, @game_parms::O ] ])
        #
        @ia.set_board(board.grid)
        expect(@ia.send(:_2_in_the_board)).to eq [:c3, 2]
      end

      # WON'T work because selecting first
      #it "returns the cols with 2 seeds of player's type" do
      #  board = Board.new([ [@game_parms::NONE, @game_parms::O, @game_parms::X],
      #                      [@game_parms::X, @game_parms::O, @game_parms::O],
      #                      [@game_parms::NONE, @game_parms::NONE, @game_parms::O ] ])
      #  #
      #  @ia.set_board(board.grid)
      #  expect(@ia.send(:_2_in_the_board)).to match_array([[:c2, 2], [:c3, 2]])
      #end

      it "returns empty array if none of the cols have 2 seeds of player's type" do
        board = Board.new([ [@game_parms::NONE, @game_parms::NONE, @game_parms::X],
                            [@game_parms::X, @game_parms::NONE, @game_parms::O],
                            [@game_parms::NONE, @game_parms::NONE, @game_parms::X ] ])
        #
        @ia.set_board(board.grid)
        expect(@ia.send(:_2_in_the_board)).to eq []
      end

      it "returns the row(s) with 2 seeds of player's type" do
        board = Board.new([ [@game_parms::NONE, @game_parms::NONE, @game_parms::X],
                            [@game_parms::O, @game_parms::NONE, @game_parms::O],
                            [@game_parms::X, @game_parms::NONE, @game_parms::NONE ] ])
        #
        @ia.set_board(board.grid)
        expect(@ia.send(:_2_in_the_board)).to eq [:r2, 2]
      end

      it "returns the diag(s) with 2 seeds of player's type" do
        board = Board.new([ [@game_parms::NONE, @game_parms::NONE, @game_parms::O],
                            [@game_parms::NONE, @game_parms::O, @game_parms::X],
                            [@game_parms::X, @game_parms::NONE, @game_parms::NONE ] ])
        #
        @ia.set_board(board.grid)
        expect(@ia.send(:_2_in_the_board)).to eq [:d1, 2]
      end

    end

    context "#2 seeds on a row, col, diag for opponent" do
      # symetry with previous tests (for me)

      it "returns the first row with 2 seeds of opponent player's type" do
        board = Board.new([ [@game_parms::NONE, @game_parms::X, @game_parms::X],
                            [@game_parms::X, @game_parms::NONE, @game_parms::O],
                            [@game_parms::NONE, @game_parms::NONE, @game_parms::O ] ])
        #
        @ia.set_board(board.grid)
        expect(@ia.send(:_2_in_the_board, @game_parms::X)).to eq [:r1, 2]
      end
    end

  end

end
