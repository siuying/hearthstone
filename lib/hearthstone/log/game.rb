require_relative "./game_turn"
require_relative "./game_player"
require 'json'

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
          @turns << GameTurn.new(number: number, player: player, timestamp: timestamp)
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

      def to_hash
        players_hash = players.values.collect(&:to_hash)
        turns_hash = turns.collect(&:to_hash)

        {
          mode: mode, 
          players: players_hash, 
          turns: turns_hash, 
          results: results
        }
      end

      def to_json
        to_hash.to_json
      end
    end
  end
end