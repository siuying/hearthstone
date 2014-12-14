require 'json'
require 'set'

require_relative './card_store'

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

      def name
        card.name
      end

      def to_s
        "<Entity ##{id} \"#{card.name}\">"
      end
    end

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

    class Game
      attr_reader :store, :entities, :players

      def initialize(store=CardStore.new)
        @store = store
        @entities = {}
        @players = []
      end

      ## Events

      def add_player(id: nil, name: nil, first_player: nil, hero_id: nil, hero_card_id: nil, hero_power_id: nil, hero_power_card_id: nil)
        hero = entity_with_id(hero_id, card_id: hero_card_id)
        hero_power = entity_with_id(hero_power_id, card_id: hero_power_card_id)
        player = Player.new(id: id, name: name, first_player: first_player, hero: hero, hero_power: hero_power)
        self.players << player
      end

      def open_card(id: nil, card_id: nil)
        entity_with_id(id).card = card_with_card_id(card_id)
      end

      def card_revealed(id: nil, card_id: nil)
        entity_with_id(id).card = card_with_card_id(card_id)
      end

      def card_added_to_deck(player_id: nil, id: nil, card_id: nil)
        entity = entity_with_id(id, card_id: card_id)
        entity.card = card_with_card_id(card_id)
        player = player_with_id(player_id)
        raise "Player #{player_id} not found!" unless player

        player.move_card(entity, :deck)
      end

      def card_received(player_id: nil, id: nil, card_id: nil)
        entity = entity_with_id(id, card_id: card_id)
        entity.card = card_with_card_id(card_id)
        player = player_with_id(player_id)
        raise "Player #{player_id} not found!" unless player

        player.move_card(entity, :hand)
      end

      def card_drawn(player_id: nil, id: nil, card_id: nil)
        entity = entity_with_id(id, card_id: card_id)
        entity.card = card_with_card_id(card_id)
        player = player_with_id(player_id)
        raise "Player #{player_id} not found!" unless player

        player.move_card(entity, :hand)
      end

      def card_attached(attachment_id: nil, target_id: nil)
        target      = entity_with_id(target_id)
        attachment  = entity_with_id(attachment_id)
        target.attach(attachment)
      end

      def apply_damage(id: nil, amount: 0)
        target = entity_with_id(id)
        target.damaged = amount
      end

      def card_played(player_id: nil, id: nil)
        player = player_with_id(player_id)
        target = entity_with_id(id)
        raise "Player #{player_id} not found!" unless player

        player.move_card(target, :play)
      end

      def card_destroyed(player_id: nil, id: nil)
        player = player_with_id(player_id)
        target = entity_with_id(id)
        raise "Player #{player_id} not found!" unless player

        player.move_card(target, :graveyard)
      end

      def card_put_in_play(player_id: nil, id: nil, card_id: nil)
        entity = entity_with_id(id, card_id: card_id)
        entity.card = card_with_card_id(card_id)
        player = player_with_id(player_id)
        raise "Player #{player_id} not found!" unless player

        player.move_card(entity, :play)
      end

      ## Accessors

      def entity_with_id(id, card_id: nil)
        entity = entities[id]
        unless entity
          entity = Entity.new(id: id, card: card_with_card_id(card_id))
          entities[id] = entity
        end
        entity
      end

      def player_with_id(id)
        self.players.detect{|p| p.id == id}
      end

      def card_with_card_id(card_id)
        card = nil
        if card_id && card_id != ""
          card = self.store.card_with_id(card_id)
          raise "Card #{card_id} not found!" unless card
        end
        card
      end
    end
  end
end