require 'json'
require_relative './card'

module Hearthstone
  module Models
    class CardStore
      STORE_FILE = "./AllSetsAllLanguages.json"

      attr_reader :cards

      def initialize(lang="enUS")
        filename = File.join(File.dirname(__FILE__), STORE_FILE)
        config = JSON(File.read(filename))
        @cards = {}

        if config[lang]
          config[lang].each do |set, cards_data|
            cards_data.each do |data|
              card = Card.new
              card.name = data["name"]
              card.cost = data["cost"]
              card.type = data["type"]

              card.rarity = data["rarity"]
              card.faction = data["faction"]
              card.text = data["text"]
              card.mechanics = data["mechanics"]

              card.flavor = data["flavor"]
              card.artist = data["artist"]
              card.attack = data["attack"]
              card.health = data["health"]
              card.collectible = data["collectible"]
              card.id = data["id"]
              card.elite = data["elite"]

              @cards[card.id] = card
            end
          end
        else
          raise "language '#{lang}'' not found!"
        end
      end

      def card_with_id(id)
        @cards[id]
      end
    end
  end
end