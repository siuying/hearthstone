require_relative "../../../lib/hearthstone"

require 'pry'

describe Hearthstone::Log::GameLogger do
  let(:delegate) { double(:delegate) }
  let(:subject) { Hearthstone::Log::GameLogger.new(delegate) }

  context "#log_file" do
    it "parse basic game info" do
      filename = File.join(File.dirname(__FILE__), "../../fixtures/gamelog1.log")
      File.open(filename) do |file|
        expect(delegate).to receive(:on_game_over) do |game|
          expect(game.players.count).to eq(2)

          zardeine = game.players[0]
          expect(zardeine).to_not be_nil
          expect(zardeine.first_player).to eq(false)

          siuying = game.players[1]
          expect(siuying).to_not be_nil
          expect(siuying.first_player).to eq(true)

          expect(game.mode).to eq(:ranked)
          expect(game.completed?).to eq(true)
          expect(game.turns.count).to eq(12)
          expect(game.turns.first.number).to eq(0)
          expect(game.turns.last.number).to eq(11)
        end

        log = file.read
        subject.log_file(log)
      end
    end

    it "parse log file #2" do
      filename = File.join(File.dirname(__FILE__), "../../fixtures/gamelog2.log")
      File.open(filename) do |file|
        games = []
        expect(delegate).to receive(:on_game_over).twice do |game|
          games << game
        end

        log = file.read
        subject.log_file(log)

        game = games.last
        expect(game.mode).to eq(:ranked)
        expect(game.players.count).to eq(2)
        expect(game.completed?).to eq(true)
        expect(game.turns.count).to eq(25)
        expect(game.turns.first.number).to eq(0)
        expect(game.turns.last.number).to eq(24)
      end
    end
  end
end