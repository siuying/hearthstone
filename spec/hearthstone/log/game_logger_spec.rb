require_relative "../../../lib/hearthstone"

require 'pry'

describe Hearthstone::Log::GameLogger do
  let (:subject) { Hearthstone::Log::GameLogger.new }

  context "#parse" do
    it "parse basic game info" do
      filename = File.join(File.dirname(__FILE__), "../../fixtures/gamelog2.log")
      File.open(filename) do |file|
        log = file.read
        result = subject.parse(log)
        binding.pry
      end
    end
  end
end