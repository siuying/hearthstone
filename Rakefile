require 'bundler'
Bundler.require
require "bundler/gem_tasks"

desc "Compile heathstone into js"
task :compile do
  require 'opal/util'
  require 'opal/sprockets/environment'

  Opal::Processor.arity_check_enabled = false
  Opal::Processor.const_missing_enabled = false
  Opal::Processor.dynamic_require_severity = :warning
  env = Opal::Environment.new
  env.append_path "lib"

  build_dir = ENV['DIR'] || 'build'
  files = Dir['{lib}/*.rb'].map { |lib| File.basename(lib, '.rb') }
  width = files.map(&:size).max

  files.each do |lib|
    print "* building #{lib}...".ljust(width+'* building ... '.size)
    $stdout.flush
    
    src = env[lib].to_s

    File.open("#{build_dir}/#{lib}.js", 'w+') { |f| f << src }
    print "done. ("
    print "development: #{('%.2f' % (src.size/1000.0)).rjust(6)}KB"
    puts ")."
  end
end