require_relative "../../../lib/hearthstone/models"


describe Hearthstone::Models::CardStore do
  let(:store) { Hearthstone::Models::CardStore.new }

  context "#card_with_id" do
    it "returns the card with specific id" do
      jenkins = store.card_with_id("EX1_116")
      expect(jenkins.name).to eq("Leeroy Jenkins")

      jenkins2 = store.card_with_id("EX1_116")
      expect(jenkins2).to eq(jenkins)
    end
  end
end