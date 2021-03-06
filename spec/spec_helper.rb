require 'bundler'
Bundler.setup

SPEC_ROOT = File.dirname(__FILE__)

RSpec.configure do |config|
  config.mock_with :rspec
end

Dir[File.join(SPEC_ROOT, '../lib/**/*.rb')].each{ |file| require file }

