# frozen_string_literal: true

require "simplecov"
require "simplecov_json_formatter"
SimpleCov.start do
  add_filter "/spec/"
  enable_coverage :branch
  minimum_coverage line: 100, branch: 100
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::JSONFormatter
  ])
end

require "turbo_rspec"

require "logger"
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/object/blank"
require "action_cable"
ActionCable.server.config.logger = Logger.new(nil)
ActionCable.server.config.cable = {"adapter" => "test"}

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
