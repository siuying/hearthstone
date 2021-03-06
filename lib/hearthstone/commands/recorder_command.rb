require 'claide'
require 'json'

require 'fileutils'
require 'file/tail'

require_relative '../log'

class RecorderCommand < CLAide::Command
  attr_reader :input, :output, :config, :complete

  self.description = 'Record hearthstone games.'
  self.command = 'hearthstone-recorder'
  self.arguments = []

  def self.options
    [
      ['--input-path', 'File path of the Hearthstone log files.'],
      ['--config-path', 'Hearthstone config file path. (Default: ~/Library/Preferences/Blizzard/Hearthstone/log.config)'],
      ['--output-path', 'File path of the output record files. (Default: ~/Documents/hearthstone-recorder)'],
      ['--complete', 'Read the log file completely and re-create every games. Default: only watch for new games.']
    ].concat(super)
  end

  def initialize(argv)
    @input = argv.option('input-path', "#{Dir.home}/Library/Logs/Unity/Player.log")
    @output = argv.option('output-path', "#{Dir.home}/Documents/hearthstone-recorder")
    @config = argv.option('config-path', "#{Dir.home}/Library/Preferences/Blizzard/Hearthstone/log.config")
    @complete = argv.flag?('complete', false)
    super
  end

  def validate!
    super

    unless Dir.exists? self.output
      Dir.mkdir(self.output)
    end

    configurator = Hearthstone::Log::Configurator.new(self.config)
    if configurator.needs_config?
      puts "Configure Hearthstone, if hearthstone is running, please restart it. (#{self.config})"
      configurator.configure
    end
  end

  def run
    logger = Hearthstone::Log::GameLogger.new(self)

    if self.complete
      logger.log_file(File.open(self.input).read)
    end

    params = {}
    params[:backward] = 10 unless self.complete

    File::Tail::Logfile.open(self.input, params) do |file|
      begin
        file.interval = 10
        file.tail do |line|
          logger.log_line(line)
        end
      rescue Interrupt
      end
    end
  end

  # when game over, write the logs to output folder
  def on_game_over(game)
    json = game.to_json
    filename = game.filename + ".json"

    puts "Game recorded: #{game.players.first.name} vs #{game.players.last.name}"
    File.open(File.join(self.output, filename), "w") do |f|
      f.write(json)
    end
  end

  def on_game_mode(mode)
    puts "Game mode detected: #{mode}"
  end

  def on_event(event, data)
    # puts "event: #{event.to_s} -> #{data}"
  end
end