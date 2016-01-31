require_relative '../shared/game_parms'

module TicTacToe

  module Base

    class Player

      @@nb_player = 0
      @@game_parms = TicTacToe::Shared::GameParms.setup()

      attr_reader :name, :type

      def initialize(input)
        _nb_play = @@game_parms::MAX_PLAYER
        raise ArgumentError,
              "no more than #{_nb_play} allowed" if @@nb_player >= _nb_play
        raise ArgumentError,
              "input hash must not empty" if input == {} || !input.is_a?(Hash)
        #
        @name  = input.fetch(:name) { "foo_#{rand(100)}" }
        @type  = input.fetch(:type) { @@game_parms.poss_type.collect {|k, v| k if v == 0} }
        @board = input[:board]      # actually the grid portion of the board
        @@game_parms.poss_type[@type] = 1
        @@nb_player += 1           # ex. init { X: 0, O: 0 }, select O => { X: 0, O: 1 }
        #                          # so next player type will be X
      end

      def set_board(board)
        @board = board
      end

      def self.reset
        # class level access
        @@nb_player = 0
        @@game_parms.poss_type =
          @@game_parms.valid_played_sym.inject({}) {|h, v| h.merge({v.to_s.to_sym => 0})}
      end

      def is_IA_S?   # is IA with Strategy
        false
      end

      #
      # self.singleton_methods       ===> [:reset]
      #
      # self.instance_methods(false) ===> [:name, :type]
      #

      if $VERBOSE
        puts "[#{self}] ==> singleton (or class) methods: #{self.singleton_methods}"
        puts "[#{self}] ==> instance methods: #{self.instance_methods(false)}"
      end

    end # Player

  end
end
