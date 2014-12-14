module Hearthstone
  module Models
    # represent an object in game
    class Entity
      attr_accessor :id, :card, :damaged
      attr_reader :attachments

      def initialize(id: nil, card: nil)
        @id = id
        @card = card
        @damaged = 0
        @attachments = []
      end

      def eql?(other)
        other.equal?(id) || id == other.id
      end

      def hash
        id.hash
      end

      def attach(card)
        attachments << card
      end

      def detach(card)
        attachments.delete(card)
      end

      def current_health
        if self.card
          [0, self.card.health - damaged].max
        else
          0
        end
      end

      def attack
        self.card.attack
      end

      def name
        card.name
      end

      def to_s
        attachment_names = attachments.collect(&:name)
        attachment_str = ""
        if attachment_names.count > 0
          attachment_str = attachment_names.join(", ")
        end

        if card
          case card.type
          when "Minion"
            "##{id} #{card.name} (#{attack}/#{current_health}) #{attachment_str}"
          else
            "##{id} #{card.name}"
          end
        else
          "##{id} Hidden"
        end
      end
    end
  end
end