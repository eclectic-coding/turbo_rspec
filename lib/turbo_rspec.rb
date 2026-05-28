# frozen_string_literal: true

require_relative "turbo_rspec/version"
require_relative "turbo_rspec/configuration"
require_relative "turbo_rspec/matchers"

module TurboRspec
  class Error < StandardError; end

  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end

if defined?(RSpec)
  RSpec.configure do |config|
    config.include TurboRspec::Matchers, type: :request if TurboRspec.configuration.auto_include &&
      Gem.loaded_specs.key?("turbo-rails")
  end
end
