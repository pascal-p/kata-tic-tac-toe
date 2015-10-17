require 'spec_helper'

module TicTacToe

  describe Player do

    context "#initialized" do

      after(:example) do
        Player.send(:reset)
      end

      it "raises an exception when empty hash is provided" do
        expect { Player.new {} }.to raise_error(ArgumentError)
        expect { Player.new [] }.to raise_error(ArgumentError)
        expect { Player.new "" }.to raise_error(ArgumentError)
      end
      
      it "succeeds with a valid input" do
        input = { name: "John", type: 'X' }
        player = Player.new input
        expect(player.name).to eq input[:name]
        expect(player.type).to eq input[:type]
      end

      it "does not allow more than 2 players" do
        inp = [ { name: "John", type: 'X' },
                { name: "James", type: 'O' } ]
        p1 = Player.new inp[0]
        p2 = Player.new inp[1]
        [p1, p2].each_with_index do |p, ix|
          expect(p.name).to eq inp[ix][:name]
          expect(p.type).to eq inp[ix][:type]
        end
        #
        expect { Player.new inp[0] }.to raise_error(ArgumentError)        
      end      
      
    end
    
  end

end
