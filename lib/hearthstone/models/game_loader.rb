require 'json'

require_relative './game'

module Hearthstone
  module Models
    class GameLoader
      def self.load_from_hash(data)

        game = Game.new

        data[:players].each do |player|
          game.add_player(id: player[:id], name: player[:name], first_player: player[:first_player], 
            hero_id: player[:hero][:id], hero_card_id: player[:hero][:card_id], 
            hero_power_id: player[:hero_power][:id], hero_power_card_id: player[:hero_power][:card_id])
        end

        game
      end
    end
  end
end