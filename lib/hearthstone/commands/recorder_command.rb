require 'claide'
require 'json'

require 'fileutils'
require 'file/tail'

require_relative '../log'

class RecorderCommand < CLAide::Command
  attr_reader :input, :output, :complete

  self.description = 'Record hearthstone games.'
  self.command = 'hearthstone-recorder'
  self.arguments = []

  def self.options
    [
      ['--input-path', 'File path of the Hearthstone log files.'],
      ['--output-path', 'File path of the output record files. (Default: ~/Documents/hearthstone-recorder)'],
      ['--complete', 'Read the log file completely and re-create every games. Default: only watch for new games.']
    ].concat(super)
  end

  def initialize(argv)
    @input = argv.option('input-path', "#{Dir.home}/Library/Logs/Unity/Player.log")
    @output = argv.option('output-path', "#{Dir.home}/Documents/hearthstone-recorder")
    @complete = argv.flag?('complete', false)

    unless Dir.exists? @output
      Dir.mkdir(@output)
    end

    super
  end

  def validate!
    super
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
    filename = filename_with_game(game)

    puts "Game recorded: #{game.players.first.name} vs #{game.players.last.name}"
    File.open(File.join(self.output, filename), "w") do |f|
      f.write(json)
    end
  end

  def on_game_mode(mode)
    puts "Game mode detected: #{mode}"
  end

  private

  def filename_with_game(game)
    timestamp = game.turns.detect {|t| t.timestamp != nil }.timestamp.to_s rescue "0"
    player1 = game.players.first.name
    player2 = game.players.last.name
    return "hs_#{timestamp}_#{player1}_vs_#{player2}.json"
  end
end