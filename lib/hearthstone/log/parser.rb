module Hearthstone
  module Log
    class Parser
      GAME_MODE_MAPPINGS = {
        "RegisterScreenPractice" => :practice, 
        "RegisterScreenTourneys" => :casual,
        "RegisterScreenForge" => :arena,
        "RegisterScreenFriendly" => :friendly
      }

      def initialize
      end

      def parse_line(line)
        case line
        when /^Initialize engine version/
          return [:startup]

        when /\[Bob\] ---(\w+)---/
          mode = GAME_MODE_MAPPINGS[$1]
          return [:mode, mode] if mode

        when /\[Power\] .* Begin Spectating/
          return [:begin_spectator_mode]

        when /\[Power\] .* End Spectator Mode/
          return [:end_spectator_mode]

        when /\[LoadingScreen\] LoadingScreen.OnSceneLoaded\(\) - prevMode=.* currMode=DRAFT/
          return [:mode, :arena]

        when /.*name=rank_window.*/
          return [:mode, :ranked]

        when /\[Bob\] legend rank (\d*)/
          rank = $1.to_i
          return [:legend, rank] if rank > 0


        when /\[Power\] GameState.DebugPrintPower\(\) -\s*FULL_ENTITY.*Creating ID=(\d*) CardID=(?!GAME)(?!HERO)(.+)/
          id = $1.to_i
          card = $2
          return [:open_card, id, card]

        when /\[Power\] GameState.DebugPrintPower\(\) -\s*TAG_CHANGE Entity=\[.*id=(\d*).* cardId=(.*) player=(\d)\] tag=(.*) value=(.*)/
          id = $1.to_i
          card_id = $2
          player = $3.to_i
          type = $4
          amount = $5.to_i
          return parse_power_tag_change_entity(type, id, card_id, player, amount)

        when /\[Power\] GameState.DebugPrintPower\(\) -\s*TAG_CHANGE Entity=(.*) tag=(.*) value=(.*)/
          player = $1
          type = $2
          state = $3
          return parse_power_tag_change(type, player, state)

        when /\[Power\] GameState.SendChoices\(\) -\s*m_chosenEntities\[0\]=\[name=(.*) id=(\d*) zone=SETASIDE.*cardId=(.*) player=(\d)\]/
          name = $1
          id = $2.to_i
          card_id = $3.to_i
          player = $4.to_i
          return [:choose, name, card_id, id, player]

        when /\[Power\] GameState.DebugPrintPower\(\).*TAG_CHANGE Entity=\[name=.* id=.* zone=PLAY zonePos=0 cardId=(.*) player=(\d)\] tag=EXHAUSTED value=1/
          card_id = $1
          player = $2.to_i
          return [:hero_power, card_id, player]

        when /\[Zone\] ZoneChangeList\.ProcessChanges\(\) - id=(\d*) local=(.*) \[name=(.*) id=(\d*) zone=(.*) zonePos=(\d*) cardId=(.*) player=(\d*)\] zone from (.*) -> (.*)/
          zone_id = $1
          local = $2
          card = $3
          id = $4
          card_zone = $5
          zone_pos = $6
          card_id = $7
          player = $8
          from_zone = $9
          to_zone = $10
          return card_change(card_zone, from_zone, to_zone, card, card_id, player.to_i, id.to_i)

        when /\[Zone\] ZoneChangeList\.ProcessChanges\(\) - id=(\d*) local=(.*) \[id=(\d*) cardId=(.*) type=(.*) zone=(.*) zonePos=(\d*) player=(\d*)\] zone from (.*) -> (.*)/
          zone_id = $1
          local = $2
          id = $3
          card_id = $4
          card_zone = $6
          zone_pos = $7
          card_id = $8
          player = $9
          from_zone = $10
          to_zone = $11
          return card_change(card_zone, from_zone, to_zone, "", card_id, player.to_i, id.to_i)

        else

        end
      end

      private
      def parse_power_tag_change(type, player, state)
        case type
        when "PLAYER_ID"
          return [:player_id, player, state.to_i]
        when "FIRST_PLAYER"
          return [:first_player, player]
        when "PLAYSTATE"
          return [:game_over, player, state]
        when "TURN_START"
          if player == "GameEntity"
            return [:game_start]
          else
            return [:turn_start, player, state.to_i]
          end
        when "TURN"
          return [:turn, state.to_i]
        end
      end

      def parse_power_tag_change_entity(type, id, card_id, player, amount)
        case type
        when "DAMAGE"
          return [:damaged, id: id, card_id: card_id, player: player, amount: amount]
        when "ATTACKING"
          return [:attack, id: id, card_id: card_id, player: player]
        when "DEFENDING"
          return [:attacked, id: id, card_id: card_id, player: player]
        when "CARD_TARGET"
          return [:card_target, id: id, card_id: card_id, player: player, target: amount]
        end
      end

      def parse_card_change(card_zone, from_zone, to_zone, card, card_id, player, id)
      end
    end
  end
end