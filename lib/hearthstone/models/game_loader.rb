require 'json'

require_relative './game'

module Hearthstone
  module Models
    class GameLoader
      attr_accessor :data
      attr_reader :game

      def initialize(data)
        @data = data
        @game = Game.new
      end

      def load_players
        data[:players].each do |player|
          game.add_player(id: player[:id], name: player[:name], first_player: player[:first_player], 
            hero_id: player[:hero][:id], hero_card_id: player[:hero][:card_id], 
            hero_power_id: player[:hero_power][:id], hero_power_card_id: player[:hero_power][:card_id])
        end
      end

      def load_turns
        data[:turns].each do |turn|
          load_turn(number: turn[:number], events: turn[:events])
        end
      end

      def load_turn(number: 0, events: [])
        game.turn = number

        events.each do |event|
          load_event(event[0], event[1])
        end
      end

      def load_event(name, data)
        event_sym = name.to_sym
        case event_sym
        when :open_card, :card_received, :card_revealed, :card_played, :card_added_to_deck, :card_drawn, :card_discarded, :card_destroyed, :card_put_in_play
          game.send(event_sym, data)
        when :damaged
          game.apply_damage(id: data[:id], amount: data[:amount])
        when :attached
          game.card_attached(attachment_id: data[:id], target_id: data[:target])
        end          
      end

    end
  end
end