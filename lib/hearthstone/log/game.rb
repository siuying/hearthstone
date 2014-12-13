require_relative "./game_turn"
require_relative "./game_player"

module Hearthstone
  module Log
    class Game
      attr_accessor :mode
      attr_reader :turns, :players, :results

      def initialize(mode)
        @mode = mode

        @players = {}
        @results = {}
        @turns = []

        add_turn(number: 0, player: nil, timestamp: nil)
      end

      def add_turn(number: number, player: player, timestamp: timestamp)
        if !self.current_turn || number > self.current_turn.number
          @turns.push(GameTurn.new(number: number, player: player, timestamp: timestamp))
        end
      end

      def current_turn
        @turns.last
      end

      def player_with_name(name)
        player = players[name]
        unless player
          player = GamePlayer.new(name)
          players[name] = player
        end
        player
      end
    end
  end
end