require 'json'
require 'set'

require_relative './card_store'

module Hearthstone
  module Models
    # represent an object in game
    class Entity
      attr_accessor :id, :card, :zone
      def initialize(id: id, card: card, zone: zone=nil)
        @id = id
        @card = card
        @zone = zone
      end

      def eql?(other)
        other.equal?(id) || id == other.id
      end

      def hash
        id.hash
      end
    end

    class Player
      attr_reader :id, :name, :first_player
      attr_accessor :hero, :hero_power
      attr_reader :deck, :hand, :play, :graveyard, :setaside

      def initialize(id: id, name: name, first_player: first_player, hero: hero, hero_power: hero_power)
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
    end

    class Game
      attr_reader :store, :entities, :players

      def initialize(store=CardStore.new)
        @store = store
        @entities = {}
        @players = []
      end

      def add_player(id: id, name: name, first_player: first_player, hero_id: hero_id, hero_card_id: hero_card_id, hero_power_id: hero_power_id, hero_power_card_id: hero_power_card_id)
        hero = entity_with_id(hero_id, card_id: hero_card_id)
        hero_power = entity_with_id(hero_power_id, card_id: hero_power_card_id)
        player = Player.new(id: id, name: name, first_player: first_player, hero: hero, hero_power: hero_power)
        self.players << player
      end

      def open_card(id: id, card_id: card_id)
        entity_with_id(id).card = card_with_card_id(card_id)
      end

      def card_revealed(id: id, card_id: card_id)
        entity_with_id(id).card = card_with_card_id(card_id)
      end

      def card_added_to_deck(player_id: player_id, id: id, card_id: card_id)
        entity = entity_with_id(id, card_id: card_id)
        entity.card = card_with_card_id(card_id)
        player = player_with_id(player_id)
        raise "Player #{player_id} not found!" unless player

        player.move_card(entity, :deck)
      end

      def card_received(player_id: player_id, id: id, card_id: card_id)
        entity = entity_with_id(id, card_id: card_id)
        entity.card = card_with_card_id(card_id)
        player = player_with_id(player_id)
        raise "Player #{player_id} not found!" unless player

        player.move_card(entity, :hand)
      end

      def card_drawn(player_id: player_id, id: id, card_id: card_id)
        entity = entity_with_id(id, card_id: card_id)
        entity.card = card_with_card_id(card_id)
        player = player_with_id(player_id)
        raise "Player #{player_id} not found!" unless player

        player.move_card(entity, :hand)
      end

      def process_turn(turn)
      end

      def entity_with_id(id, card_id: card_id)
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