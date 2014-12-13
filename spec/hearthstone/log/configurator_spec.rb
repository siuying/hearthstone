require_relative "../../../lib/hearthstone"
require 'tempfile'

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

  context "#configure" do
    before(:each) do
      @file = Tempfile.new("configurator")
    end

    after(:each) do
      @file.close
    end

    it "write configuration file" do
      subject = Hearthstone::Log::Configurator.new(@file.path)
      subject.configure

      data = @file.read
      expect(data).to match(/\[Zone\]/)
      expect(data).to match(/\[Power\]/)
    end

    it "append configuration file" do
      File.open(@file.path, 'w') do |f|
        config = """[Hello]
foo=bar
"""
        f.write(config)
      end

      subject = Hearthstone::Log::Configurator.new(@file.path)
      subject.configure

      data = @file.read
      expect(data).to match(/\[Zone\]/)
      expect(data).to match(/\[Power\]/)
      expect(data).to match(/\[Hello\]/)
      expect(data).to match(/foo=bar/)
    end
  end
end