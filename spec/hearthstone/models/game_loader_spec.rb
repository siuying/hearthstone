require_relative "../../../lib/hearthstone/models"
require 'json'

describe Hearthstone::Models::GameLoader do
  before(:all) {
    filename = File.join(File.dirname(__FILE__), "../../fixtures/game1.json")
    @data = JSON.parse(open(filename).read, symbolize_names: true)
  }

  context "#load_players" do
    it "should load players" do
      loader = Hearthstone::Models::GameLoader.new(@data)
      loader.load_players

      game = loader.game
      expect(game.players.count).to eq(2)

      first = game.players.first
      expect(first.name).to eq("ALzard")
      expect(first.hero.name).to eq("Thrall")

      last = game.players.last
      expect(last.name).to eq("siuying")
      expect(last.hero.name).to eq("Rexxar")
    end
  end

  context "Load Games" do
    before(:each) do
      @loader = Hearthstone::Models::GameLoader.new(@data)
      @loader.load_players
      @game = @loader.game
    end

    context "#load_event" do
      it "should load open card event" do
        @loader.load_event(:open_card, id: 5, card_id: "CS2_101")

        entity = @game.entity_with_id(5)
        expect(entity.card.id).to eq("CS2_101")
      end

      it "should load card received event" do
        @loader.load_event(:card_received, player_id: 2, id: 7, card_id: "CS2_101")

        entity = @game.entity_with_id(7)
        expect(entity.card.id).to eq("CS2_101")

        player = @game.player_with_id(2)
        expect(player.hand).to include(entity)
      end

      it "should load card reveal event" do
        @loader.load_event(:open_card, id: 7, card_id: "")
        @loader.load_event(:card_revealed, id: 7, card_id: "CS2_101")

        entity = @game.entity_with_id(7)
        expect(entity.card.id).to eq("CS2_101")
      end

      it "should load card_added_to_deck event" do
        @loader.load_event(:card_added_to_deck, player_id: 2, id: 7, card_id: "")

        entity = @game.entity_with_id(7)
        expect(entity.card).to be_nil

        player = @game.player_with_id(2)
        expect(player.deck).to include(entity)
      end

      it "should handle card_drawn event" do
        @loader.load_event(:card_drawn, player_id: 2, id: 7, card_id: "CS2_101")

        entity = @game.entity_with_id(7)
        player = @game.player_with_id(2)
        expect(player.hand).to include(entity)
      end

      it "should handle card_destroyed event" do
        @loader.load_event(:card_destroyed, player_id: 1, id: 26)

        entity = @game.entity_with_id(26)
        player = @game.player_with_id(1)
        expect(player.graveyard).to include(entity)
      end

      it "should handle card_put_in_play event" do
        @loader.load_event(:card_put_in_play, player_id: 2, id: 7, card_id: "CS2_101")

        entity = @game.entity_with_id(7)
        player = @game.player_with_id(2)
        expect(player.play).to include(entity)
      end

      it "should handle damaged event" do
        @loader.load_event(:damaged, id: 7, amount: 2)

        entity = @game.entity_with_id(7)
        expect(entity.damaged).to eq(2)
      end

      it "should handle attached event" do
        @loader.load_event(:open_card, id: 7, card_id: "")
        @loader.load_event(:open_card, id: 26, card_id: "")
        @loader.load_event(:attached, id: 26, target: 7)

        entity = @game.entity_with_id(7)
        attachment = @game.entity_with_id(26)
        expect(entity.attachments).to include(attachment)
      end
      
    end
  end

end