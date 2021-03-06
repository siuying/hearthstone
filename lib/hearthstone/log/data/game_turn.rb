module Hearthstone
  module Log
    class GameTurn
      attr_accessor :number, :player, :timestamp
      attr_reader :events

      def initialize(number: nil, player: nil, timestamp: nil)
        @events = []
        @number = number
        @player = player
        @timestamp = timestamp        
      end

      def add_event(event, data, line=nil)
        if line
          @events.push([event, data, line])
        else
          @events.push([event, data])
        end
      end

      def to_hash
        {
          number: number,
          player: player,
          timestamp: timestamp,
          events: events
        }
      end
    end
  end
end