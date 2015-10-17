# spec/spec_board.rb
require 'spec_helper'

module TicTacToe

  module Helper
    extend self

    def manufacture(board, dim, orient=:col)
      ix = rand dim
      sym, sym_c = ix % 2 == 0 ? [TicTacToe::Shared::GameCst::O, TicTacToe::Shared::GameCst::X] :
                     [TicTacToe::Shared::GameCst::X, TicTacToe::Shared::GameCst::O]
      board, ix =
             if orient == :col
               col_oriented(board, dim, ix, sym)
             elsif orient == :diag
               diag_oriented(board, dim, ix, sym) # ix is used for diag up or down
             else                    
               row_oriented(board, dim, ix, sym) # :row or :line
             end        
      [ix, sym_c, board]
    end

    private
    def col_oriented(board, dim, ic, sym)
      (0...dim).each {|il| board.grid.set_cell(il, ic, sym)} # 1 column with spec value
      [board, ic]
    end

    def row_oriented(board, dim, il, sym)
      (0...dim).each {|ic| board.grid.set_cell(il, ic, sym)}
      [board, il]
    end

    def diag_oriented(board, dim, _, sym)
      ix = rand dim
      j = (ix % 2) == 1 ? (dim - 1) : 0
      (0...dim).each {|i| board.grid.set_cell(i, (j - i).abs, sym)}
      [board, j]
    end
  end

  describe Board do
    
    before(:example) do
      @board = Board.new
      @game_const = TicTacToe::Shared::GameCst.setup
    end

    context "#initialized" do

      it "sets the grid (0, 0) to be set with @game_const::NONE" do
        expect(@board.grid[0, 0]).to eq(@game_const::NONE)
      end

      it "sets the grid with 3 rows" do
        expect(@board.grid.nb_rows).to eq(@game_const::DIM)
      end

      it "sets the grid with 3 cols" do
        expect(@board.grid.nb_cols).to eq(@game_const::DIM)
      end

      it "sets the grid with 3*3 cells" do
        expect(@board.grid.to_a.size).to eq(@game_const::DIM * @game_const::DIM)
      end

    end

    context "#columns" do

      it "returns the requested column" do
        o = TicTacToe::Cell.new(@game_const::O)
        board = Board.new([ [@game_const::NONE, @game_const::O, @game_const::NONE],
                            [@game_const::NONE, @game_const::O, @game_const::NONE],
                            [@game_const::NONE, @game_const::O, @game_const::NONE ] ])
        # puts board.to_s
        # set a line to a specific (same) value and check this value
        expect(board.grid.col(1)).to match_array([o, o, o])
      end

      it "returns false whenever any cols contains a mix of symbols" do
        ic, sym_c,@board = Helper.manufacture(@board, @game_const::DIM, :col)
        il = rand @game_const::DIM
        @board.grid.set_cell!(il, ic, sym_c)
        expect(@board.send(:cols_win_case?)).to be false
      end

      #
      # cols win
      #
      it "returns true if any col. contains the 3 same symbols" do
        _, _, @board = Helper.manufacture(@board, @game_const::DIM, :col)
        expect(@board.send(:cols_win_case?)).to be true
      end

    end

    context "#rows" do

      it "returns the requested line/row" do
        board = Board.new([ [@game_const::NONE, @game_const::NONE, @game_const::NONE],
                            [@game_const::O, @game_const::O, @game_const::O],
                            [@game_const::NONE, @game_const::NONE, @game_const::NONE ] ])
        # puts board.to_s
        # set a line to a specific (same) value and check this value
        expect(board.grid.line(1)).to match_array([TicTacToe::Cell.new(@game_const::O),
                                                   TicTacToe::Cell.new(@game_const::O),                                                   TicTacToe::Cell.new(@game_const::O)])
      end

      #
      # rows/lines win
      #
      it "returns false whenever any lines contains a mix of symbols" do
        il, sym_c, @board = Helper.manufacture(@board, @game_const::DIM, :row)
        ic = rand @game_const::DIM
        @board.grid.set_cell!(il, ic, sym_c)
        expect(@board.send(:lines_win_case?)).to be false
      end

      #
      # lines win
      #
      it "returns true if any lines contains the 3 same symbols" do
        _, _, @board = Helper.manufacture(@board, @game_const::DIM, :row)
        expect(@board.send(:lines_win_case?)).to be true
      end

    end

    context "#diag" do

      it "returns false whenever any diagonals contains a mix of symbols" do
        j, sym, @board = Helper.manufacture(@board, @game_const::DIM, :diag)
        i = rand @game_const::DIM
        @board.grid.set_cell!(i, (j - i).abs, sym)
        expect(@board.send(:diags_win_case?)).to be false
      end

      #
      # diags win
      #
      it "returns true if any diagonal contains the 3 same symbols" do
        _, _, @board = Helper.manufacture(@board, @game_const::DIM, :diag)
        expect(@board.send(:diags_win_case?)).to be true
      end

    end

    context "#game_over? predicate" do

      it "returns [fake] :winner if winner? is true" do
        allow(@board).to receive(:winner?) { true }
        expect(@board.game_over?).to eq :winner
      end

      it "returns [fake] :draw if winner? is false and draw? is true" do
        allow(@board).to receive(:winner?) { false }
        allow(@board).to receive(:draw?) { true }
        expect(@board.game_over?).to eq :draw
      end
      
      it "returns [fake] false if winner? is false and draw? is false" do
        allow(@board).to receive(:winner?) { false }
        allow(@board).to receive(:draw?) { false }
        expect(@board.game_over?).to be false
      end
      
      it "returns :winner if winner? is true" do
        ary = [
          [ [@game_const::O, @game_const::O, @game_const::X],   # a win on a column
            [@game_const::X, @game_const::O, @game_const::O], 
            [@game_const::X, @game_const::O, @game_const::X ]
          ],
          [
            [@game_const::O, @game_const::O, @game_const::O],   # a win on a row
            [@game_const::X, @game_const::X, @game_const::O],
            [@game_const::X, @game_const::O, @game_const::X ]
          ],
          [
            [@game_const::O, @game_const::O, @game_const::X],  # a win on a diag
            [@game_const::O, @game_const::X, @game_const::O],
            [@game_const::X, @game_const::O, @game_const::X]
          ]          
        ]
        ary.each do |a|
          board = Board.new(a)
          expect(board.game_over?).to eq :winner
        end
      end

      it "returns :draw if winner? is false and draw? is true" do
        ary = [
          [ [@game_const::X, @game_const::O, @game_const::O],
            [@game_const::O, @game_const::X, @game_const::X], 
            [@game_const::X, @game_const::O, @game_const::O ]
          ],
          [
            [@game_const::O, @game_const::X, @game_const::O],
            [@game_const::X, @game_const::X, @game_const::O],
            [@game_const::O, @game_const::O, @game_const::X ]
          ],
          [
            [@game_const::X, @game_const::O, @game_const::X],
            [@game_const::O, @game_const::O, @game_const::X],
            [@game_const::X, @game_const::X, @game_const::O]
          ]          
        ]
        ary.each do |a|
          board = Board.new(a)
          expect(board.game_over?).to eq :draw
        end
      end

      it "returns false when winner? is false and draw? is false" do
         ary = [
          [
            [@game_const::X, @game_const::O, @game_const::O],
            [@game_const::NONE, @game_const::X, @game_const::X], 
            [@game_const::X, @game_const::O, @game_const::O ]
          ],
          [
            [@game_const::O, @game_const::X, @game_const::O],
            [@game_const::X, @game_const::X, @game_const::O],
            [@game_const::O, @game_const::O, @game_const::NONE ]
          ],
          [
            [@game_const::X, @game_const::O, @game_const::X],
            [@game_const::O, @game_const::O, @game_const::NONE],
            [@game_const::X, @game_const::X, @game_const::NONE]
          ],
          [
            [@game_const::X, @game_const::NONE, @game_const::X],
            [@game_const::NONE, @game_const::NONE, @game_const::NONE],
            [@game_const::NONE, @game_const::NONE, @game_const::NONE]
          ],
        ]
         ary.each do |a|
           board = Board.new(a)
           expect(board.game_over?).to be false
         end
      end
      
    end

    context "#draw? predicate" do
      it "returns true if draw? is true - full" do
        board = Board.new([ [@game_const::O, @game_const::O, @game_const::X],
                            [@game_const::X, @game_const::O, @game_const::O],
                            [@game_const::O, @game_const::X, @game_const::X ] ])
        expect(board.send(:draw?)).to be true
      end

      #it "returns true if draw? is true - filled but last last cell" do
      #  board = Board.new([ [@game_const::O, @game_const::O, @game_const::X],
      #                      [@game_const::X, @game_const::NONE, @game_const::X],
      #                      [@game_const::O, @game_const::X, @game_const::O ] ])
      #  expect(board.send(:draw?)).to be true
      #end

      it "returns false if the board is filled with less than 7 (or equal)" do
        board = Board.new([ [@game_const::NONE, @game_const::O, @game_const::X],
                            [@game_const::X, @game_const::NONE, @game_const::X],
                            [@game_const::O, @game_const::X, @game_const::O ] ])
        expect(board.send(:draw?)).to be false
      end      
      
    end

    context "#winner? predicate" do
      it "returns true whenever a win configuration is found - diag" do
        # let's manufacture a possible win:
        board = Board.new([ [@game_const::O, @game_const::O, @game_const::X],
                            [@game_const::NONE, @game_const::X, @game_const::NONE],
                            [@game_const::X, @game_const::O, @game_const::NONE ] ])
        expect(board.send(:winner?)).to be true
      end

      it "returns true whenever a win configuration is found - line" do
        # let's manufacture a possible win:
        board = Board.new([ [@game_const::O, @game_const::O, @game_const::X],
                            [@game_const::X, @game_const::X, @game_const::X],
                            [@game_const::NONE, @game_const::O, @game_const::O ] ])
        expect(board.send(:winner?)).to be true
      end

      it "returns true whenever a win configuration is found - col" do
        # let's manufacture a possible win:
        board = Board.new([ [@game_const::O, @game_const::X, @game_const::X],
                            [@game_const::O, @game_const::X, @game_const::O],
                            [@game_const::NONE, @game_const::X, @game_const::O ] ])
        expect(board.send(:winner?)).to be true
      end

    end

    context "coordinate transfo." do

      it "returns the grid coordinates given a move" do

        [ [0, 0], [0, 1], [0, 2],
          [1, 0], [1, 1], [1, 2],
          [2, 0], [2, 1], [2, 2] ].each_with_index do |(x, y), ix|
          _x, _y = @board.grid.to_coord(ix + 1)
          expect(x).to eq x
          expect(y).to eq y
        end
      end
      
    end
    
    context "grid - cell set" do      

      it "does not overwrite a grid cell" do
        board = Board.new([ [@game_const::O, @game_const::X, @game_const::X],
                            [@game_const::O, @game_const::X, @game_const::O],
                            [@game_const::NONE, @game_const::X, @game_const::O ] ])
        m = rand(@game_const::DIM) * rand(@game_const::DIM) + 1
        expect(board.set_cell(m, @game_const::O)).to eq(@game_const::NONE)
      end

      it "can set a cell to a specify value" do
        m = rand(@game_const::DIM) * rand(@game_const::DIM) + 1
        expect(@board.set_cell(m, @game_const::O)).to eq(@game_const::O)
      end

      it "does not set a cell if the value is not allowed" do
        m = rand(@game_const::DIM) * rand(@game_const::DIM) + 1
        expect(@board.set_cell(m, 'Z')).to eq(@game_const::NONE)
      end
      
    end
    
  end
  
end
