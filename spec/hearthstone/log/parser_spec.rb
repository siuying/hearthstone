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

  it "returns choice" do
    result = parser.parse_line("[Power] GameState.SendChoices() - id=3 ChoiceType=GENERAL")
    expect(result).to eq([:choice_type, "GENERAL"])

    result = parser.parse_line("[Power] GameState.SendChoices() -   m_chosenEntities[0]=[name=Feign Death id=38 zone=HAND zonePos=3 cardId=GVG_026 player=2]")
    expect(result).to eq([:choose, id: 38, card_id: 'GVG_026', player: 2])

    result = parser.parse_line("[Power] GameState.SendChoices() -   m_chosenEntities[0]=[name=Undertaker id=8 zone=SETASIDE zonePos=0 cardId=FP1_028 player=1]")
    expect(result).to eq([:choose, id: 8, card_id: 'FP1_028', player: 1])
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

  context "returns process change" do
    it "handles hands" do
      line = "[Zone] ZoneChangeList.ProcessChanges() - id=47 local=False [name=Reversing Switch id=72 zone=HAND zonePos=7 cardId=PART_006 player=1] zone from  -> FRIENDLY HAND"
      result = parser.parse_line(line)
      expect(result).to eq([:card_received, player: 1, id: 72, card_id: "PART_006"])

      line = "[Zone] ZoneChangeList.ProcessChanges() - id=1 local=False [id=22 cardId= type=INVALID zone=HAND zonePos=4 player=1] zone from  -> OPPOSING HAND"
      result = parser.parse_line(line)
      expect(result).to eq([:card_received, player: 1, id: 22, card_id: ""])

      line = "[Zone] ZoneChangeList.ProcessChanges() - id=16 local=False [id=57 cardId= type=INVALID zone=HAND zonePos=0 player=2] zone from OPPOSING DECK -> OPPOSING HAND"
      result = parser.parse_line(line)
      expect(result).to eq([:card_drawn, player: 2, id: 57, card_id: ""])

      line = "[Zone] ZoneChangeList.ProcessChanges() - id=27 local=False [name=Boulderfist Ogre id=10 zone=HAND zonePos=0 cardId=CS2_200 player=1] zone from FRIENDLY DECK -> FRIENDLY HAND"
      result = parser.parse_line(line)
      expect(result).to eq([:card_drawn, player: 1, id: 10, card_id: 'CS2_200'])

      line = "[Zone] ZoneChangeList.ProcessChanges() - id=20 local=False [name=Leper Gnome id=26 zone=HAND zonePos=2 cardId=EX1_029 player=1] zone from OPPOSING PLAY -> OPPOSING HAND"
      result = parser.parse_line(line)
      expect(result).to eq([:card_returned, player: 1, id: 26, card_id: 'EX1_029'])

      line = "[Zone] ZoneChangeList.ProcessChanges() - id=45 local=False [name=Harvest Golem id=10 zone=HAND zonePos=1 cardId=EX1_556 player=1] zone from FRIENDLY PLAY -> FRIENDLY HAND"
      result = parser.parse_line(line)
      expect(result).to eq([:card_returned, player: 1, id: 10, card_id: 'EX1_556'])
    end

    it "handles play" do
      line = "[Zone] ZoneChangeList.ProcessChanges() - id=1 local=True [name=Loot Hoarder id=57 zone=HAND zonePos=2 cardId=EX1_096 player=2] zone from FRIENDLY HAND -> FRIENDLY PLAY"
      result = parser.parse_line(line)
      expect(result).to eq([:card_played, player: 2, id: 57, card_id: 'EX1_096'])

      line = "[Zone] ZoneChangeList.ProcessChanges() - id=8 local=False [name=Pint-Sized Summoner id=34 zone=PLAY zonePos=1 cardId=EX1_076 player=1] zone from OPPOSING HAND -> OPPOSING PLAY"
      result = parser.parse_line(line)
      expect(result).to eq([:card_played, player: 1, id: 34, card_id: 'EX1_076'])

      line = "[Zone] ZoneChangeList.ProcessChanges() - id=84 local=False [name=Ashbringer id=84 zone=PLAY zonePos=0 cardId=EX1_383t player=1] zone from  -> OPPOSING PLAY (Weapon)"
      result = parser.parse_line(line)
      expect(result).to eq([:card_put_in_play, player: 1, id: 84, card_id: 'EX1_383t'])

      line = "[Zone] ZoneChangeList.ProcessChanges() - id=1 local=False [name=Jaina Proudmoore id=4 zone=PLAY zonePos=0 cardId=HERO_08 player=1] zone from  -> FRIENDLY PLAY (Hero)"
      result = parser.parse_line(line)
      expect(result).to eq([:set_hero, player: 1, id: 4, card_id: 'HERO_08'])

      line = "[Zone] ZoneChangeList.ProcessChanges() - id=1 local=False [name=Gul'dan id=36 zone=PLAY zonePos=0 cardId=HERO_07 player=2] zone from  -> OPPOSING PLAY (Hero)"
      result = parser.parse_line(line)
      expect(result).to eq([:set_hero, player: 2, id: 36, card_id: 'HERO_07'])

      line = "[Zone] ZoneChangeList.ProcessChanges() - id=1 local=False [name=Steady Shot id=5 zone=PLAY zonePos=0 cardId=DS1h_292 player=1] zone from  -> FRIENDLY PLAY (Hero Power)"
      result = parser.parse_line(line)
      expect(result).to eq([:set_hero_power, player: 1, id: 5, card_id: 'DS1h_292'])

      line = "[Zone] ZoneChangeList.ProcessChanges() - id=1 local=False [name=Steady Shot id=37 zone=PLAY zonePos=0 cardId=DS1h_292 player=2] zone from  -> OPPOSING PLAY (Hero Power)"
      result = parser.parse_line(line)
      expect(result).to eq([:set_hero_power, player: 2, id: 37, card_id: 'DS1h_292'])
    end

    it "handles deck" do
      line = "[Zone] ZoneChangeList.ProcessChanges() - id=2 local=False [name=Sludge Belcher id=46 zone=DECK zonePos=3 cardId=FP1_012 player=2] zone from FRIENDLY HAND -> FRIENDLY DECK"
      result = parser.parse_line(line)
      expect(result).to eq([:card_reshuffled, player: 2, id: 46, card_id: "FP1_012"])

      line = "[Zone] ZoneChangeList.ProcessChanges() - id=3 local=False [id=69 cardId= type=INVALID zone=DECK zonePos=2 player=2] zone from OPPOSING HAND -> OPPOSING DECK"
      result = parser.parse_line(line)
      expect(result).to eq([:card_reshuffled, player: 2, id: 69, card_id: ""])

      line = "[Zone] ZoneChangeList.ProcessChanges() - id=1 local=False [id=38 cardId= type=INVALID zone=DECK zonePos=0 player=2] zone from  -> FRIENDLY DECK"
      result = parser.parse_line(line)
      expect(result).to eq([:card_added_to_deck, player: 2, id: 38, card_id: ""])

      line = "[Zone] ZoneChangeList.ProcessChanges() - id=1 local=False [id=6 cardId= type=INVALID zone=DECK zonePos=0 player=1] zone from  -> OPPOSING DECK"
      result = parser.parse_line(line)
      expect(result).to eq([:card_added_to_deck, player: 1, id: 6, card_id: ""])
    end

    it "handles graveyard" do
      line = "[Zone] ZoneChangeList.ProcessChanges() - id=21 local=False [name=Webspinner id=65 zone=GRAVEYARD zonePos=2 cardId=FP1_011 player=2] zone from FRIENDLY PLAY -> FRIENDLY GRAVEYARD"
      result = parser.parse_line(line)
      expect(result).to eq([:card_destroyed, player: 2, id: 65, card_id: "FP1_011"])

      line = "[Zone] ZoneChangeList.ProcessChanges() - id=42 local=False [name=Animal Companion id=50 zone=GRAVEYARD zonePos=0 cardId=NEW1_031 player=2] zone from  -> OPPOSING GRAVEYARD"
      result = parser.parse_line(line)
      expect(result).to eq([:card_discarded, player: 2, id: 50, card_id: "NEW1_031"])

      line = "[Zone] ZoneChangeList.ProcessChanges() - id=86 local=False [name=Uther Lightbringer id=4 zone=GRAVEYARD zonePos=0 cardId=HERO_04 player=1] zone from OPPOSING PLAY (Hero) -> OPPOSING GRAVEYARD"
      result = parser.parse_line(line)
      expect(result).to eq([:hero_destroyed, player: 1, id: 4, card_id: "HERO_04"])

    end

    it "handles secrets" do
      line = "[Zone] ZoneChangeList.ProcessChanges() - id=80 local=False [id=30 cardId= type=INVALID zone=SECRET zonePos=0 player=1] zone from OPPOSING DECK -> OPPOSING SECRET"
      result = parser.parse_line(line)
      expect(result).to eq([:card_put_in_play, player: 1, id: 30, card_id: ''])

      line = "[Zone] ZoneChangeList.ProcessChanges() - id=29 local=False [name=Explosive Trap id=43 zone=SECRET zonePos=0 cardId=EX1_610 player=2] zone from FRIENDLY DECK -> FRIENDLY SECRET"
      result = parser.parse_line(line)
      expect(result).to eq([:card_put_in_play, player: 2, id: 43, card_id: 'EX1_610'])

      line = "[Zone] ZoneChangeList.ProcessChanges() - id=45 local=False [name=Freezing Trap id=66 zone=SETASIDE zonePos=0 cardId=EX1_611 player=2] zone from FRIENDLY DECK -> "
      result = parser.parse_line(line)
      expect(result).to eq([:card_setaside, player: 2, id: 66, card_id: 'EX1_611'])
    end
  end

end