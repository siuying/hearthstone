require_relative "../../../lib/hearthstone/models"
require 'json'

describe Hearthstone::Models::GameLoader do
  before(:all) {
    filename = File.join(File.dirname(__FILE__), "../../fixtures/game1.json")
    @data = JSON.parse(open(filename).read, symbolize_names: true)
  }

  context "::load_from_hash" do
    before(:all) {
      @game = Hearthstone::Models::GameLoader.load_from_hash(@data)
    }

    it "load players" do
      expect(@game.players.count).to eq(2)

      first = @game.players.first
      expect(first.name).to eq("siuying")
      expect(first.hero.name).to eq("Rexxar")

      second = @game.players.last
      expect(second.name).to eq("화이트베리")
      expect(second.hero.name).to eq("Uther Lightbringer")
    end
  end
end