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
      expect(first.name).to eq("siuying")
      expect(first.hero.name).to eq("Rexxar")

      second = game.players.last
      expect(second.name).to eq("화이트베리")
      expect(second.hero.name).to eq("Uther Lightbringer")
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

    end
  end

end