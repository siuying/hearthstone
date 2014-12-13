module Hearthstone
  module Log
    class GamePlayer
      attr_accessor :id, :name, :first_player
      attr_accessor :hero, :hero_power

      def initialize(name)
        @name = name
        @first_player = false
      end

      def to_hash
        {
          id: id, 
          name: name, 
          first_player: first_player, 
          hero: hero,
          hero_power: hero_power
        }
      end

    end
  end
end