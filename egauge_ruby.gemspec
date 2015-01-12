# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'egauge_ruby/version'

Gem::Specification.new do |spec|
  spec.name          = "egauge_ruby"
  spec.version       = EgaugeRuby::VERSION
  spec.authors       = ["Joshua Burke"]
  spec.email         = ["burke.joshua.james@gmail.com"]
  spec.summary       = %q{Fetch, parse, and export Egauge measurements.}
  spec.description   = %q{Basic functionality for using Egauge devices from a Ruby client.}
  spec.homepage      = "https://github.com/Dangeranger/egauge_ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_development_dependency "awesome_print"
end
