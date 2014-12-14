require_relative "../../../lib/hearthstone/models"

describe Hearthstone::Models::Game do
  let(:game) { Hearthstone::Models::Game.new }

  context "#add_player" do
    it "adds players into game" do
      game.add_player(id: 2, name: "siuying", first_player: true, hero_id: 36, hero_card_id: "HERO_05", hero_power_id: 37, hero_power_card_id: "DS1h_292")
      game.add_player(id: 1, name: "화이트베리", first_player: false, hero_id: 4, hero_card_id: "HERO_04", hero_power_id: 5, hero_power_card_id: "CS2_101")

      player1 = game.player_with_id(1)
      expect(player1.name).to eq("화이트베리")

      player2 = game.player_with_id(2)
      expect(player2.name).to eq("siuying")
    end
  end

  context "#open_card" do
    it "adds card into game" do
      game.open_card(id: 5, card_id: "CS2_101")

      entity = game.entity_with_id(5)
      expect(entity.card).to_not be_nil
      expect(entity.card.name).to eq("Reinforce")
    end
  end

  context "#card_revealed" do
    it "shows card from game" do
      game.open_card(id: 34, card_id: "")
      entity = game.entity_with_id(34)
      expect(entity.card).to be_nil

      game.card_revealed(id: 34, card_id: "FP1_020")
      entity = game.entity_with_id(34)
      expect(entity.card).to_not be_nil
      expect(entity.card.name).to eq("Avenge")
    end
  end

  context "Game Started" do
    before(:each) do
      game.add_player(id: 2, name: "siuying", first_player: true, hero_id: 36, hero_card_id: "HERO_05", hero_power_id: 37, hero_power_card_id: "DS1h_292")
      game.add_player(id: 1, name: "화이트베리", first_player: false, hero_id: 4, hero_card_id: "HERO_04", hero_power_id: 5, hero_power_card_id: "CS2_101")
    end

    context "#card_added_to_deck" do  
      it "adds card into player deck" do
        game.card_added_to_deck(player_id: 1, id: 7, card_id: "")

        entity = game.entity_with_id(7)
        expect(entity).to_not be_nil
        expect(entity.card).to be_nil # not yet know the card

        player = game.player_with_id(1)
        expect(player).to_not be_nil
        expect(player.deck).to include(entity)
      end
    end

    context "#card_received" do
      it "adds card into player hand" do
        player = game.player_with_id(2)

        game.card_added_to_deck(player_id: 2, id: 58, card_id: "")
        expect(player).to_not be_nil
        expect(player.hand).to be_empty
        expect(player.deck).to_not be_empty
        
        game.card_received(player_id: 2, id: 58, card_id: "EX1_556")

        entity = game.entity_with_id(58)
        expect(entity).to_not be_nil
        expect(entity.card).to eq(game.card_with_card_id("EX1_556"))
        expect(player.hand).to include(entity)
        expect(player.deck).to be_empty
      end
    end

    context "#card_drawn" do
      it "adds card into player hands" do
        player = game.player_with_id(2)

        expect(player).to_not be_nil
        expect(player.hand).to be_empty

        game.card_drawn(player_id: 2, id: 58, card_id: "EX1_556")
        entity = game.entity_with_id(58)
        expect(entity).to_not be_nil
        expect(entity.card).to eq(game.card_with_card_id("EX1_556"))
        expect(player.hand).to include(entity)
      end
    end

    context "#card_attached" do
      it "adds effect to a card" do
        player = game.player_with_id(2)
        game.open_card(id: 69, card_id: "FP1_028e")
        game.open_card(id: 57, card_id: "FP1_028")

        target = game.entity_with_id(57)
        attachment = game.entity_with_id(69)
        game.card_attached(attachment_id: attachment.id, target_id: target.id)

        expect(target.attachments).to include(attachment)
      end
    end

    context "#apply_damage" do
      it "apply damage to a card" do
        player = game.player_with_id(2)
        game.open_card(id: 57, card_id: "FP1_028")

        target = game.entity_with_id(57)
        game.apply_damage(id: 57, amount: 2)

        expect(target.damaged).to eq(2)
      end
    end

    context "#card_played" do
      it "move cards in play" do
        player = game.player_with_id(2)
        game.open_card(id: 57, card_id: "FP1_028")

        target = game.entity_with_id(57)
        game.card_played(player_id: 2, id: 57)
        expect(player.play).to include(target)
      end
    end

    context "#card_destroyed" do
      it "move cards to graveyard" do
        player = game.player_with_id(2)
        game.open_card(id: 57, card_id: "FP1_028")

        target = game.entity_with_id(57)
        game.card_destroyed(player_id: 2, id: 57)
        expect(player.graveyard).to include(target)
      end
    end

    context "#card_put_in_play" do
      it "put cards in play" do
        player = game.player_with_id(2)

        game.card_put_in_play(player_id: 2, id: 78, card_id: "GVG_103")
        target = game.entity_with_id(78)
        expect(target).to_not be_nil
        expect(target.card.id).to eq("GVG_103")
        expect(player.play).to include(target)
      end
    end
  end

end