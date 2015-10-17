require 'spec_helper'

module TicTacToe

  describe Cell do

    before :example do
      @cell = Cell.new
      @game_parms = TicTacToe::Shared::GameParms.setup
    end
    
    context "#initialized" do      
      
      it "is init. with a default value of '_'" do
        expect(@cell.val).to eq @game_parms::NONE
      end

      it "expects a X" do
        v = @game_parms::X
        cellX = Cell.new(v)
        expect(cellX.val).to eq v
      end

      it "expects a O" do        
        v = @game_parms::O
        cellO = Cell.new(v)
        expect(cellO.val).to eq v
      end
      
      it "expects a '_' when given an input which neither O nor X" do
        v = 'z'
        cell = Cell.new(v)
        expect(cell.val).to eq @game_parms::NONE
      end
      
    end

    context "#set_unconditional" do

      it "should be equal to the valid symbol passed to the setter" do
        v = @game_parms::O
        @cell.val = v
        expect(@cell.val).to eq v
      end

      it "should be equal to the last valid symbol passed to the setter" do
        [ @game_parms::O, @game_parms::X, @game_parms::O ].each do |v|
          @cell.val = v
          expect(@cell.val).to eq v
        end
      end

      it "should ignored invalid values" do
        iv = @cell.val
        @cell.val = 'Z'
        expect(@cell.val).to eq iv
      end
            
    end

    context "#set_conditional" do

      it "should be equal to the valid symbol passed to the setter if initial value was '_'" do
        iv = @cell.val
        v = @game_parms::O
        @cell.set_val(v)
        expect(@cell.val).to eq v
        expect(iv).to eq @game_parms::NONE
      end

      it "should be equal to the first valid symbol passed to the setter, ignoring the following ones" do
        list = [ @game_parms::O, @game_parms::X, @game_parms::O, @game_parms::X ].shuffle
        first = list.first
        list.each do |v|
          @cell.set_val(v)
          expect(@cell.val).to eq first
        end
      end

      it "should ignored invalid values" do
        iv = @cell.val
        @cell.set_val('Z')
        expect(@cell.val).to eq iv
      end
      
    end

  end
  
end
