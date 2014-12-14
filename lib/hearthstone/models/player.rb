module Hearthstone
  module Models
    class Player
      attr_reader :id, :name, :first_player
      attr_accessor :hero, :hero_power
      attr_reader :deck, :hand, :play, :graveyard, :setaside

      def initialize(id: nil, name: nil, first_player: nil, hero: nil, hero_power: nil)
        @id = id
        @name = name
        @first_player = first_player
        @hero = hero
        @hero_power = hero_power

        @deck = Set.new
        @hand = Set.new
        @play = Set.new
        @graveyard = Set.new
        @setaside = Set.new
      end

      def move_card(card, to_zone)
        [:deck, :hand, :play, :graveyard, :setaside].each do |zone|
          if to_zone != zone
            self.send(zone).delete(card)
          else
            self.send(to_zone) << card
          end
        end
      end

      def to_s
        "<Player ##{id} \"#{name}\">"
      end
    end
  end
end