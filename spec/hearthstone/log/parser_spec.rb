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

end