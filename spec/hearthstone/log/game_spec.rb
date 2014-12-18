require_relative "../../../lib/hearthstone/log/data/game"

describe Hearthstone::Log::Game, "#add_turn" do
  it "should set player name" do
    game = Hearthstone::Log::Game.new(:ranked)
    game.player_with_id_or_name(name: "siuying", id: 1).first_player = false
    game.player_with_id_or_name(name: "UNKNOWN HUMAN PLAYER", id: 2).first_player = true
    game.add_turn(number: 1, player: "Lorewalker Chow", timestamp: 1400000)

    expect(game.player_with_id_or_name(id: 2).name).to eq("Lorewalker Chow")
  end
end