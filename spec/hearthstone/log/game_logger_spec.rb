require_relative "../../../lib/hearthstone"

require 'pry'

describe Hearthstone::Log::GameLogger do
  let (:subject) { Hearthstone::Log::GameLogger.new }

  context "#parse" do
    it "parse basic game info" do
      filename = File.join(File.dirname(__FILE__), "../../fixtures/gamelog1.log")
      File.open(filename) do |file|
        log = file.read
        subject.parse(log)

        game = subject.games.first
        zardeine = game.players["zardeine"]
        expect(zardeine).to_not be_nil
        expect(zardeine.first_player).to eq(false)

        siuying = game.players["siuying"]
        expect(siuying).to_not be_nil
        expect(siuying.first_player).to eq(true)

        expect(game.turns.count).to eq(12)
        expect(game.turns.first.number).to eq(0)
        expect(game.turns.last.number).to eq(11)
      end
    end
  end
end