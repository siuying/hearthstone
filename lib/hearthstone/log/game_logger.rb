require_relative "./parser"
require_relative "./game"

module Hearthstone
  module Log
    class GameLogger
      attr_reader :logfile, :parser

      attr_reader :games
      attr_accessor :mode, :spectator_mode, :game

      def initialize(parser=Parser.new)
        @parser = parser

        @mode = nil
        @spectator_mode = false 
        @game = Game.new(self.mode)
        @games = []
      end

      def parse(io)
        parser.parse(io) do |event, data|
          case event
          when :game_start
            on_game_start
          when :game_over
            on_game_over(data)
          when :turn_start
            on_turn_start(data)
          when :turn
            on_turn(data)
          when :begin_spectator_mode
            on_begin_spectator_mode
          when :end_spectator_mode
            on_end_spectator_mode
          when :mode
            on_game_mode(data)
          when :player_id
            on_player_id(data)
          when :first_player
            on_first_player(data)
          else
            on_event(event, data)
          end
        end
      end

      private
      def on_game_mode(mode)
        self.game.mode = mode
      end

      def on_begin_spectator_mode
        self.spectator_mode = true
      end

      def on_end_spectator_mode
        self.spectator_mode = false
      end

      def on_game_start()
        # start
      end

      def on_player_id(name: name, player_id: player_id)
        self.game.player_with_name(name).id = player_id
      end

      def on_first_player(name: name)
        self.game.player_with_name(name).first_player = true
      end

      def on_game_over(name: name, state: state)
        self.game.results[name] = state

        if self.game.results.size == 2
          on_game_end_cleanup
        end
      end

      def on_turn_start(name: name, timestamp: timestamp)
        self.game.current_turn.player = name
        self.game.current_turn.timestamp = timestamp
      end

      def on_turn(turn)
        self.game.add_turn(number: turn)
      end

      def on_event(event, data)
        self.game.current_turn.add_event(event, data)
      end

      def on_game_end_cleanup
        self.games << self.game
        self.game = Game.new(self.mode)
      end
    end
  end
end