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

        @results = {}
        @players = []
        @turns = []

        add_turn(number: 0, player: nil, timestamp: nil)
      end

      # proceed to next turn
      def add_turn(number: nil, player: nil, timestamp: nil)
        @turns << GameTurn.new(number: number, player: player, timestamp: timestamp)

        if player && number
          is_first_player = (number % 2 == 1)
          the_player = players.detect {|p| p.first_player == is_first_player}
          the_player.name = player if the_player
        end
      end

      # current turn
      def current_turn
        @turns.last
      end

      # create or get the player, with given id or name
      def player_with_id_or_name(id: nil, name: nil)
        player = players.detect {|p| (id && p.id == id) || (name && p.name == name) }
        unless player
          player = GamePlayer.new(name: name, id: id)
          players << player
        end
        player
      end

      # if the game is completed
      def completed?
        self.results.count == 2
      end

      # convert the game into hash
      def to_hash
        players_hash = players.collect(&:to_hash)
        turns_hash = turns.collect(&:to_hash)

        {
          mode: mode, 
          players: players_hash, 
          turns: turns_hash, 
          results: results
        }
      end

      # convert the game into JSON
      def to_json
        JSON.pretty_generate(to_hash)
      end

      # A unique filename for this Game
      def filename
        timestamp = turns.detect {|t| t.timestamp != nil }.timestamp rescue Time.now.to_i
        time = Time.at(timestamp).strftime("%Y%m%d_%H%M%S")
        player1 = players.first.name
        player2 = players.last.name
        "#{time}_#{mode}_#{player1}_vs_#{player2}"
      end
    end
  end
end