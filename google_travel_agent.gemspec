# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'google_travel_agent/version'

Gem::Specification.new do |spec|
  spec.name          = "google_travel_agent"
  spec.version       = GoogleTravelAgent::VERSION
  spec.authors       = ["Shaun Dern"]
  spec.email         = ["shaun@substantial.com"]
  spec.description   = %q{Simplify the Google API}
  spec.summary       = %q{Simplify the Google API}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec'

  spec.add_dependency "google-api-client", "~> 0.6.3"
end

