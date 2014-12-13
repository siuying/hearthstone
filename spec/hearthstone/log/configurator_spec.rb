require_relative "../../../lib/hearthstone"

describe Hearthstone::Log::Configurator do
  context "#needs_config?" do
    it "should needs config for nonexisted config file" do
      filename = File.join(File.dirname(__FILE__), "../../fixtures/not_found")
      subject = Hearthstone::Log::Configurator.new(filename)
      expect(subject.needs_config?).to eq(true)
    end

    it "should needs config for incompleted config file" do
      filename = File.join(File.dirname(__FILE__), "../../fixtures/empty_config.config")
      subject = Hearthstone::Log::Configurator.new(filename)
      expect(subject.needs_config?).to eq(true)
    end

    it "should not need config for completed config file" do
      filename = File.join(File.dirname(__FILE__), "../../fixtures/completed.config")
      subject = Hearthstone::Log::Configurator.new(filename)
      expect(subject.needs_config?).to eq(false)
    end
  end
end