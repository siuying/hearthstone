require_relative "../../../lib/hearthstone"

describe Hearthstone::Log::Parser, "#parse_line" do
  let (:parser) { Hearthstone::Log::Parser.new }
  it "returns startup on app start" do
    result = parser.parse_line("Initialize engine version: 4.5.5p3 (b8dc95101aa8)")
    expect(result).to eq([:startup])
  end

  it "returns game modes" do
    result = parser.parse_line("[Bob] ---RegisterScreenTourneys---")
    expect(result).to eq([:mode, :casual])

    result = parser.parse_line("[Bob] ---RegisterScreenForge---")
    expect(result).to eq([:mode, :arena])

    result = parser.parse_line("[Bob] ---RegisterScreenPractice---")
    expect(result).to eq([:mode, :practice])

    result = parser.parse_line("[Bob] ---RegisterScreenFriendly---")
    expect(result).to eq([:mode, :friendly])
  end

  it "returns spectator mode" do
    result = parser.parse_line("[Power]  Begin Spectating")
    expect(result).to eq([:begin_spectator_mode])

    result = parser.parse_line("[Power]  End Spectator Mode")
    expect(result).to eq([:end_spectator_mode])
  end

  it "returns arena and ranked mode" do
    result = parser.parse_line("[LoadingScreen] LoadingScreen.OnSceneLoaded() - prevMode=HUB currMode=DRAFT")
    expect(result).to eq([:mode, :arena])

    result = parser.parse_line("[Asset] CachedAsset.UnloadAssetObject() - unloading name=rank_window_expand family=Sound persistent=True")
    expect(result).to eq([:mode, :ranked])
  end

  it "returns legend rank" do
    result = parser.parse_line("[Bob] legend rank 10")
    expect(result).to eq([:legend, 10])

    result = parser.parse_line("[Bob] legend rank 0")
    expect(result).to be_nil
  end

  it "returns player state change" do
    result = parser.parse_line("[Power] GameState.DebugPrintPower() - TAG_CHANGE Entity=siuying tag=PLAYER_ID value=2")
    expect(result).to eq([:player_id, "siuying", 2])

    result = parser.parse_line("[Power] GameState.DebugPrintPower() - TAG_CHANGE Entity=begize tag=FIRST_PLAYER value=1")
    expect(result).to eq([:first_player, "begize"])

    result = parser.parse_line("[Power] GameState.DebugPrintPower() - TAG_CHANGE Entity=begize tag=PLAYSTATE value=WON")
    expect(result).to eq([:game_over, "begize", "WON"])

    result = parser.parse_line("[Power] GameState.DebugPrintPower() -     TAG_CHANGE Entity=siuying tag=TURN_START value=1418309639")
    expect(result).to eq([:turn_start, "siuying", 1418309639])

    result = parser.parse_line("[Power] GameState.DebugPrintPower() -     TAG_CHANGE Entity=GameEntity tag=TURN value=3")
    expect(result).to eq([:turn, 3])

    result = parser.parse_line("[Power] GameState.DebugPrintPower() - TAG_CHANGE Entity=GameEntity tag=TURN_START value=1418310864")
    expect(result).to eq([:game_start])
  end

  it "returns entity state change" do
    result = parser.parse_line("[Power] GameState.DebugPrintPower() -     TAG_CHANGE Entity=[name=Silver Hand Recruit id=71 zone=PLAY zonePos=1 cardId=CS2_101t player=1] tag=DAMAGE value=2
 ")
    expect(result).to eq([:damaged, id: 71, card_id: "CS2_101t", player: 1, amount: 2])

    result = parser.parse_line("[Power] GameState.DebugPrintPower() -     TAG_CHANGE Entity=[name=Uther Lightbringer id=4 zone=PLAY zonePos=0 cardId=HERO_04 player=1] tag=ATTACKING value=1")
    expect(result).to eq([:attack, id: 4, card_id: "HERO_04", player: 1])

    result = parser.parse_line("[Power] GameState.DebugPrintPower() -     TAG_CHANGE Entity=[name=Rexxar id=36 zone=PLAY zonePos=0 cardId=HERO_05 player=2] tag=DEFENDING value=1")
    expect(result).to eq([:attacked, id: 36, card_id: "HERO_05", player: 2])

    result = parser.parse_line("[Power] GameState.DebugPrintPower() -     TAG_CHANGE Entity=[name=Fireblast id=37 zone=PLAY zonePos=0 cardId=CS2_034 player=2] tag=CARD_TARGET value=9")
    expect(result).to eq([:card_target, id: 37, card_id: 'CS2_034', player: 2, target: 9])
  end

end