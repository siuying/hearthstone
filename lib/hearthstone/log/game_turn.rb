module Hearthstone
  module Log
    class GameTurn
      attr_accessor :number, :player, :timestamp
      attr_reader :events

      def initialize(number: number, player: player, timestamp: timestamp)
        @events = []
        @number = number
        @player = player
        @timestamp = timestamp        
      end

      def add_event(event, data)
        @events.push([event, data])
      end
    end
  end
end