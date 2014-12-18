require_relative "./parser"
require_relative "./data"

module Hearthstone
  module Log
    class GameLogger
      attr_reader :parser, :debug
      attr_accessor :game, :delegate, :mode

      def initialize(delegate, debug: false)
        @delegate = delegate
        @parser = Parser.new
        @game = Game.new(nil)
        @debug = debug
        @mode = nil
      end

      def log_file(io)
        io.each_line do |line|
          log_line(line)
        end
      end

      def log_line(line)
        result = parser.parse_line(line)
        if result
          name = result[0]
          data = result[1]
          log_line = line if self.debug
          process_event(name, data, log_line)
        end
      end

      private
      def process_event(event, data, line=nil)
        case event
        when :game_start
          # ignored
        when :game_over
          on_game_over(data)
        when :turn_start
          on_turn_start(data)
        when :turn
          on_turn(data)
        when :begin_spectator_mode, :end_spectator_mode
          # ignored
        when :mode
          on_game_mode(data)
        when :player_id
          on_player_id(data)
        when :first_player
          on_first_player(data)
        when :attack, :attacked
          # ignored
        when :set_hero
          on_set_hero(data)
        when :set_hero_power
          on_set_hero_power(data)
        when :hero_destroyed
          on_hero_destroyed(data)
        else
          if event
            on_event(event, data, line)
          end
        end
      end

      def on_game_mode(mode)
        self.mode = mode
        self.game = Game.new(mode)

        if delegate.respond_to?(:on_game_mode)
          delegate.on_game_mode(mode)
        end
      end

      def on_player_id(name: nil, player_id: nil)
        player = self.game.player_with_id_or_name(name: name, id: player_id)
        player.name = name
        player.id = player_id
      end

      def on_first_player(name: nil)
        self.game.player_with_id_or_name(name: name).first_player = true
      end

      def on_set_hero(player_id: nil, id: nil, card_id: nil, zone_pos: 0)
        self.game.player_with_id_or_name(id: player_id).hero = {id: id, card_id: card_id}
      end

      def on_set_hero_power(player_id: nil, id: nil, card_id: nil, zone_pos: 0)
        self.game.player_with_id_or_name(id: player_id).hero_power = {id: id, card_id: card_id}
      end

      def on_game_over(name: nil, state: nil)
        self.game.results[name] = state

        if delegate.respond_to?(:on_game_over)
          if self.game.completed? && self.game.results.count == 2
            delegate.on_game_over(self.game)
          end
        end
      end

      def on_hero_destroyed(player_id: nil, id: nil, card_id: nil, zone_pos: 0)
        # when hero destroyed, the game is ended, we should proceed to next game
        self.game = Game.new(self.mode)
      end

      def on_turn_start(name: nil, timestamp: nil)
        self.game.current_turn.player = name
        self.game.current_turn.timestamp = timestamp
      end

      def on_turn(turn)
        self.game.add_turn(number: turn)
      end

      def on_event(event, data, line=nil)
        self.game.current_turn.add_event(event, data, line)

        if delegate.respond_to?(:on_event)
          delegate.on_event(event, data)
        end
      end
    end
  end
end