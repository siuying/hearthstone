module Hearthstone
  module Log
    class Configurator
      attr_reader :path

      def initialize(path="~/Library/Preferences/Blizzard/Hearthstone/log.config")
        @path = path
      end

      def needs_config?
        unless File.exists?(path)
          return true
        end

        data = File.read(path)
        !(data =~ /\[Zone\]/ && data =~ /\[Power\]/)
      end

      def configure
        config = """[Zone]
LogLevel=1
FilePrinting=false
ConsolePrinting=true
ScreenPrinting=false

[Power]
LogLevel=1
ConsolePrinting=true
"""
        mode = "w"
        if File.exists?(path)
          mode = "a"
        end

        File.open(path, mode) do |f|
          f.write(config)
        end
      end
    end
  end
end