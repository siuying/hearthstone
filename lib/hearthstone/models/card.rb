module Hearthstone
  module Models
    class Card
      attr_accessor :name, :cost, :type, :rarity, :faction, :text, :mechanics, :flavor
      attr_accessor :artist, :attack, :health, :collectible, :id, :elite

      def eql?(other)
        other.equal?(id) || id == other.id
      end

      def hash
        id.hash
      end

      def to_s
        "<Card \"#{name}\">"
      end
    end
  end
end