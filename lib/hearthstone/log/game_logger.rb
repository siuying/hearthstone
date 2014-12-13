require_relative "./parser"
require_relative "./game"

module Hearthstone
  module Log
    class GameLogger
      attr_reader :logfile, :parser

      attr_accessor :mode, :spectator_mode, :turn

      def initialize(logfile, parser=Parser.new)
        @logfile = logfile
        @parser = parser

        @mode = nil
        @spectator_mode = false 
        @game = nil
        @turn = 1
      end

      def parse
        parser.parse(File.open(logfile).read) do |event, data|
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
        self.mode = mode
      end

      def on_begin_spectator_mode
        self.spectator_mode = true
      end

      def on_end_spectator_mode
        self.spectator_mode = false
      end

      def on_game_start()
        self.on_game_end_cleanup
        self.game = Game.new(self.mode)
      end

      def on_player_id(name: player, player_id: player_id)
        self.game.player_with_name(player).player_id = player_id
      end

      def on_first_player(name: player)
        self.game.player_with_name(player).first_player = true
      end

      def on_game_over(name: player, state: state)
        self.game.results[player] = state
      end

      def on_turn_start(name: player, timestamp: timestamp)
        self.game.add_turn(number: self.turn, player: player, timestamp: timestamp)
      end

      def on_turn(turn)
        self.turn = turn
      end

      def on_event(data)
        self.game.current_turn.add_event(event, data)
      end

      def on_game_end_cleanup
        self.turn = 1
        self.game = nil
      end
    end
  end
end