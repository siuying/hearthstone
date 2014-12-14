module Hearthstone
  module Log
    class Parser
      attr_accessor :debug

      def initialize
        @debug = false
      end

      def parse_line(line)
        case line
        when /^Initialize engine version/
          return [:startup]

        when /\[Power\] .* Begin Spectating/
          return [:begin_spectator_mode]

        when /\[Power\] .* End Spectator Mode/
          return [:end_spectator_mode]

        when /\[LoadingScreen\] LoadingScreen.OnSceneLoaded\(\) - prevMode=.* currMode=(.*)/
          mode = $1
          case mode
          when "DRAFT"
            return [:mode, :arena]
          when "TOURNAMENT"
            return [:mode, :ranked]
          when "ADVENTURE"
            return [:mode, :solo]
          end

        when /\[Power\] GameState.DebugPrintPower\(\) -\s*FULL_ENTITY.*Creating ID=(\d*) CardID=(?!GAME)(.+)/
          id = $1.to_i
          card = $2
          return [:open_card, id: id, card_id: card]

        when /\[Power\] GameState.DebugPrintPower\(\) -\s*TAG_CHANGE Entity=\[.*id=(\d*).* cardId=(.*?) .* ?player=(\d)\] tag=(.*) value=(.*)/
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

        when /\[Power\] GameState.SendChoices\(\) - id=(\d*) ChoiceType=(.*)/
          return [:choice_type, $2]

        when /\[Power\] GameState.DebugPrintPower\(\) - ACTION_START Entity=\[name=.* id=(\d*) .* cardId=(.*) player=(\d)\] SubType=ATTACK .* Target=\[name=.* id=(\d*) .* cardId=(.*) player=(\d)\]/
          from_id = $1.to_i
          from_card_id = $2
          from_player = $3.to_i
          to_id = $4.to_i
          to_card_id = $5
          to_player = $6.to_i
          return [:action_start, subtype: 'ATTACK', :from => {id: from_id, card_id: from_card_id, player: from_player}, :to => {id: to_id, card_id: to_card_id, player: to_player}]

        when /\[Power\] GameState.SendChoices\(\) -\s*m_chosenEntities\[0\]=\[name=(.*) id=(\d*) zone=(SETASIDE|HAND).*cardId=(.*) player=(\d)\]/
          name = $1
          id = $2.to_i
          card_id = $4
          player = $5.to_i
          return [:choose, id: id, card_id: card_id, player: player]

        when /\[Power\] GameState.DebugPrintPower\(\).*TAG_CHANGE Entity=\[name=.* id=.* zone=PLAY zonePos=0 cardId=(.*) player=(\d)\] tag=EXHAUSTED value=1/
          card_id = $1
          player = $2.to_i
          return [:hero_power, card_id: card_id, player: player]

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
          return parse_zone(card_zone, from_zone, to_zone, card, card_id, player.to_i, id.to_i)

        when /\[Zone\] ZoneChangeList\.ProcessChanges\(\) - id=(\d*) local=(.*) \[id=(\d*) cardId=(.*) type=(.*) zone=(.*) zonePos=(\d*) player=(\d*)\] zone from (.*) -> (.*)/
          zone_id = $1
          local = $2
          id = $3
          card_id = $4
          card_zone = $6
          zone_pos = $7
          player = $8
          from_zone = $9
          to_zone = $10
          return parse_zone(card_zone, from_zone, to_zone, "", card_id, player.to_i, id.to_i)

        end
      end

      private
      def parse_power_tag_change(type, player, state)
        case type
        when "PLAYER_ID"
          return [:player_id, name: player, player_id: state.to_i]
        when "FIRST_PLAYER"
          return [:first_player, name: player]
        when "PLAYSTATE"
          return [:game_over, name: player, state: state] if state == "WON" || state == "LOST"
        when "TURN_START"
          if player == "GameEntity"
            return [:game_start]
          else
            return [:turn_start, name: player, timestamp: state.to_i]
          end
        when "TURN"
          return [:turn, state.to_i]
        when "ATTACHED"
          return [:attached, id: player.to_i, target: state.to_i]
        else
          raise "unknown entity: %s, %s, %s" % [type, player, state] if debug
        end
      end

      def parse_power_tag_change_entity(type, id, card_id, player, amount)
        case type
        when "DAMAGE"
          return [:damaged, id: id, card_id: card_id, player: player, amount: amount] if amount > 0
        when "ATTACKING"
          return [:attack, id: id, card_id: card_id, player: player] if amount == 1
        when "DEFENDING"
          return [:attacked, id: id, card_id: card_id, player: player] if amount == 1
        when "CARD_TARGET"
          return [:card_target, id: id, card_id: card_id, player: player, target: amount]
        else
          raise "unknown entity: %s, %s, %s, %s, %s" % [type, id, card_id, player, amount] if debug
        end
      end

      def parse_zone(card_zone, from_zone, to_zone, card, card_id, player, id)
        if to_zone =~ /SECRET/ || from_zone =~ /SECRET/
          return parse_zone_to_secret(card_zone, from_zone, to_zone, card, card_id, player, id)
        end

        if to_zone =~ /HAND/
          return parse_zone_to_hand(card_zone, from_zone, to_zone, card, card_id, player, id)
        end

        if to_zone =~ /DECK/
          return parse_zone_to_deck(card_zone, from_zone, to_zone, card, card_id, player, id)
        end

        if to_zone =~ /PLAY/ || from_zone =~ /HAND/
          return parse_zone_to_play(card_zone, from_zone, to_zone, card, card_id, player, id)
        end

        if to_zone =~ /GRAVEYARD/
          return parse_zone_to_graveyard(card_zone, from_zone, to_zone, card, card_id, player, id)
        end

        if to_zone == ""
          return parse_zone_to_setaside(card_zone, from_zone, to_zone, card, card_id, player, id)
        end

        raise "unsupported play: %s, %s, %s, %s, %s, %s, %s" % [card_zone, from_zone, to_zone, card, card_id, player, id] if debug
      end

      def parse_zone_to_hand(card_zone, from_zone, to_zone, card, card_id, player, id)
        if (from_zone == "OPPOSING DECK" && to_zone == "OPPOSING HAND") || (from_zone == "FRIENDLY DECK" && to_zone == "FRIENDLY HAND")
          return [:card_drawn, player: player, id: id, card_id: card_id]
        end

        if (from_zone == "" && to_zone == "OPPOSING HAND") || (from_zone == "" && to_zone == "FRIENDLY HAND")
          return [:card_received, player: player, id: id, card_id: card_id]
        end

        if (from_zone == "FRIENDLY PLAY" && to_zone == "FRIENDLY HAND") || (from_zone == "OPPOSING PLAY" && to_zone == "OPPOSING HAND")
          return [:card_returned, player: player, id: id, card_id: card_id]
        end

        raise "unsupported hand: %s, %s, %s, %s, %s, %s, %s" % [card_zone, from_zone, to_zone, card, card_id, player, id] if debug
      end

      def parse_zone_to_play(card_zone, from_zone, to_zone, card, card_id, player, id)
        if (from_zone == "OPPOSING HAND" && to_zone == "") || (from_zone == "FRIENDLY HAND" && to_zone == "")
          return [:card_played, player: player, id: id, card_id: card_id]
        end

        if (from_zone == "OPPOSING HAND" && to_zone == "OPPOSING PLAY") || (from_zone == "FRIENDLY HAND" && to_zone == "FRIENDLY PLAY")
          return [:card_played, player: player, id: id, card_id: card_id]
        end

        if (from_zone == "OPPOSING DECK" && to_zone == "OPPOSING PLAY") || (from_zone == "FRIENDLY DECK" && to_zone == "FRIENDLY PLAY")
          return [:card_played, player: player, id: id, card_id: card_id]
        end

        if from_zone == "" && to_zone =~ /PLAY \(Hero\)/
          return [:set_hero, player: player, id: id, card_id: card_id]
        end

        if from_zone == "" && to_zone =~ /PLAY \(Hero Power\)/
          return [:set_hero_power, player: player, id: id, card_id: card_id]
        end

        if from_zone == "" && to_zone =~ /PLAY/
          return [:card_put_in_play, player: player, id: id, card_id: card_id]
        end

        raise "unsupported play: %s, %s, %s, %s, %s, %s, %s" % [card_zone, from_zone, to_zone, card, card_id, player, id] if debug
      end

      def parse_zone_to_deck(card_zone, from_zone, to_zone, card, card_id, player, id)
        if (from_zone == "FRIENDLY HAND" && to_zone == "FRIENDLY DECK") || (from_zone == "OPPOSING HAND" && to_zone == "OPPOSING DECK")
          return [:card_reshuffled, player: player, id: id, card_id: card_id]
        end

        if from_zone == "" && (to_zone =~ /DECK/)
          return [:card_added_to_deck, player: player, id: id, card_id: card_id]
        end

        raise "unsupported deck: %s, %s, %s, %s, %s, %s, %s" % [card_zone, from_zone, to_zone, card, card_id, player, id] if debug
      end
      
      def parse_zone_to_graveyard(card_zone, from_zone, to_zone, card, card_id, player, id)
        if from_zone == "" || from_zone =~ /HAND/
          return [:card_discarded, player: player, id: id, card_id: card_id]
        end

        if from_zone =~ /DECK/
          return [:card_discarded_from_deck, player: player, id: id, card_id: card_id]
        end

        if from_zone =~ /PLAY \(Hero\)/
          return [:hero_destroyed, player: player, id: id, card_id: card_id]
        end

        if from_zone =~ /PLAY/ || from_zone =~ /SECRET/ 
          return [:card_destroyed, player: player, id: id, card_id: card_id]
        end

        raise "unsupported gy: %s, %s, %s, %s, %s, %s, %s" % [card_zone, from_zone, to_zone, card, card_id, player, id] if debug
      end

      def parse_zone_to_secret(card_zone, from_zone, to_zone, card, card_id, player, id)
        if (from_zone == "OPPOSING HAND" && to_zone == "OPPOSING SECRET") || (from_zone == "FRIENDLY HAND" && to_zone == "FRIENDLY SECRET")
          return [:card_played, player: player, id: id, card_id: card_id]
        end

        if (from_zone == "OPPOSING DECK" && to_zone == "OPPOSING SECRET") || (from_zone == "FRIENDLY DECK" && to_zone == "FRIENDLY SECRET")
          return [:card_put_in_play, player: player, id: id, card_id: card_id]
        end

        if from_zone =~ /SECRET/ && to_zone == ""
          return [:card_revealed, player: player, id: id, card_id: card_id]
        end

        raise "unsupported secret: %s, %s, %s, %s, %s, %s, %s" % [card_zone, from_zone, to_zone, card, card_id, player, id] if debug
      end

      def parse_zone_to_setaside(card_zone, from_zone, to_zone, card, card_id, player, id)
        if from_zone =~ /PLAY/
          return [:card_setaside, player: player, id: id, card_id: card_id]
        end

        if from_zone =~ /DECK/
          return [:card_setaside, player: player, id: id, card_id: card_id]
        end

        raise "unsupported setaside: %s, %s, %s, %s, %s, %s, %s" % [card_zone, from_zone, to_zone, card, card_id, player, id] if debug
      end

    end
  end
end