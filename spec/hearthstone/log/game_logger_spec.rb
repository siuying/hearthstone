require_relative "../../../lib/hearthstone"

require 'pry'

describe Hearthstone::Log::GameLogger do
  let (:subject) { Hearthstone::Log::GameLogger.new }

  context "#parse" do
    it "parse basic game info" do
      log = File.open(File.join(File.dirname(__FILE__), "../../fixtures/gamelog1.log")).read
      result = subject.parse(log)
      binding.pry
    end
  end
end