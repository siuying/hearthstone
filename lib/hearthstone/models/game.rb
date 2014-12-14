require 'json'
require 'set'

require_relative './card_store'
require_relative './entity'
require_relative './player'

module Hearthstone
  module Models
    class Game
      attr_reader :store, :entities, :players
      attr_accessor :turn

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

      def card_revealed(id: nil, card_id: nil, player_id: nil)
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

      def apply_damage(id: nil, amount: 0, card_id: nil, player_id: nil)
        target = entity_with_id(id)
        target.damaged = amount
      end
      alias_method :damage, :apply_damage

      def card_played(player_id: nil, id: nil, card_id: nil)
        player = player_with_id(player_id)
        target = entity_with_id(id)
        target.card = card_with_card_id(card_id)
        raise "Player #{player_id} not found!" unless player
        #binding.pry

        player.move_card(target, :play)
      end

      def card_destroyed(player_id: nil, id: nil, card_id: nil)
        player = player_with_id(player_id)
        target = entity_with_id(id)
        raise "Player #{player_id} not found!" unless player

        player.move_card(target, :graveyard)
      end
      alias_method :card_discarded, :card_destroyed

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

      ## Public

      def to_s
        player1 = self.players.first
        player2 = self.players.last

        """======================= Turn ##{turn} =====================
#{player1.name} (#{player1.hero.current_health})
======================================================

#{player1.play.collect(&:to_s).join("\n")}

----------------------------------------------------

#{player2.play.collect(&:to_s).join("\n")}

======================================================
#{player2.name} (#{player2.hero.current_health})
======================================================
"""
      end
    end
  end
end