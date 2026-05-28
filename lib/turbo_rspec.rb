# frozen_string_literal: true

require_relative "turbo_rspec/version"
require_relative "turbo_rspec/configuration"
require_relative "turbo_rspec/matchers"
require_relative "turbo_rspec/capybara/matchers"

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

    def install_rspec_integration(config)
      return unless configuration.auto_include && Gem.loaded_specs.key?("turbo-rails")
      config.include Matchers, type: :request
      if Gem.loaded_specs.key?("capybara")
        config.include Capybara::Matchers, type: :system
        config.include Capybara::Matchers, type: :feature
      end
    end
  end
end

# :nocov:
if defined?(RSpec)
  RSpec.configure { |config| TurboRspec.install_rspec_integration(config) }
end
# :nocov:
