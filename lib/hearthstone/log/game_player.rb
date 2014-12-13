module Hearthstone
  module Log
    class GamePlayer
      attr_accessor :id, :name, :first_player
      attr_accessor :hero, :hero_power

      def initialize(name)
        @name = name
      end

    end
  end
end