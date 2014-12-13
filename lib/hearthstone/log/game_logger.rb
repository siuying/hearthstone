require_relative "./parser"
require_relative "./game"

module Hearthstone
  module Log
    class GameLogger
      attr_reader :parser, :debug
      attr_accessor :mode, :spectator_mode, :game, :delegate

      def initialize(delegate, debug: debug=false)
        @delegate = delegate
        @parser = Parser.new
        @game = Game.new(self.mode)

        @debug = debug
        @mode = nil
        @spectator_mode = false 
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
        else
          if event
            on_event(event, data, line)
          end
        end
      end

      def on_game_mode(mode)
        self.game.mode = mode

        if delegate.respond_to?(:on_game_mode)
          delegate.on_game_mode(mode)
        end
      end

      def on_player_id(name: name, player_id: player_id)
        player = self.game.player_with_id_or_name(name: name, id: player_id)
        player.name = name
        player.id = player_id
      end

      def on_first_player(name: name)
        self.game.player_with_id_or_name(name: name).first_player = true
      end

      def on_set_hero(player: player, id: id, card_id: card_id)
        self.game.player_with_id_or_name(id: player).hero = {id: id, card_id: card_id}
      end

      def on_set_hero_power(player: player, id: id, card_id: card_id)
        self.game.player_with_id_or_name(id: player).hero_power = {id: id, card_id: card_id}
      end

      def on_game_over(name: name, state: state)
        self.game.results[name] = state

        if self.game.results.size == 2 && self.game.completed?
          if delegate.respond_to?(:on_game_over)
            delegate.on_game_over(self.game)
          end

          self.game = Game.new(self.mode)
        end
      end

      def on_turn_start(name: name, timestamp: timestamp)
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