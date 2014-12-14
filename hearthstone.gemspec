# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hearthstone/version'

Gem::Specification.new do |spec|
  spec.name          = "hearthstone"
  spec.version       = Hearthstone::VERSION
  spec.authors       = ["Francis Chong"]
  spec.email         = ["francis@ignition.hk"]
  spec.summary       = %q{Utlities for Hearthstone.}
  spec.description   = %q{Utlities for Hearthstone. First, a game recorder.}
  spec.homepage      = "https://github.com/siuying/hearthstone"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1.0"
  spec.add_development_dependency "pry"

  spec.add_dependency "claide", "~> 0.7.0"
  spec.add_dependency "file-tail"
end
