# frozen_string_literal: true

require 'simplecov'
require 'coveralls'

SimpleCov::Formatter::MultiFormatter.new([
                                           SimpleCov::Formatter::HTMLFormatter,
                                           Coveralls::SimpleCov::Formatter
                                         ])
Coveralls.wear!
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/lib/logux/test/'
end

require 'bundler/setup'
require 'factory_bot'
require 'logux_rails'
require 'webmock/rspec'
require 'timecop'
require 'pry-byebug'
require 'rspec/live_controllers'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.include RSpec::LiveControllers::Matchers
  config.include Logux::Test::Helpers
  config.include Logux::Test::Helpers::Send
  config.include Logux::Test::Helpers::Receive, type: :controllers
  config.include Logux::Test::Helpers::Receive, type: :request
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!
  config.expose_dsl_globally = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end
