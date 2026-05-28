# frozen_string_literal: true

require_relative "turbo_rspec/version"
require_relative "turbo_rspec/configuration"
require_relative "turbo_rspec/matchers"
require_relative "turbo_rspec/helpers"
require_relative "turbo_rspec/assertions"
require_relative "turbo_rspec/shared_examples"
require_relative "turbo_rspec/capybara/matchers"

# TurboRspec provides RSpec matchers and Minitest assertions for
# {https://github.com/hotwired/turbo-rails turbo-rails}.
#
# @example Configure auto-include
#   TurboRspec.configure do |config|
#     config.auto_include = false
#   end
module TurboRspec
  # Base error class for TurboRspec.
  class Error < StandardError; end

  class << self
    # Yields the configuration object for customization.
    #
    # @yieldparam config [Configuration]
    # @return [void]
    # @example
    #   TurboRspec.configure do |config|
    #     config.auto_include = false
    #   end
    def configure
      yield configuration
    end

    # Returns the global configuration instance.
    #
    # @return [Configuration]
    def configuration
      @configuration ||= Configuration.new
    end

    # Resets configuration to defaults. Primarily for use in test suites.
    #
    # @return [void]
    def reset_configuration!
      @configuration = Configuration.new
    end

    # Installs RSpec integration — includes matchers and helpers into the
    # appropriate example groups. Called automatically when RSpec is present.
    #
    # @param config [RSpec::Core::Configuration]
    # @return [void]
    def install_rspec_integration(config)
      return unless configuration.auto_include && Gem.loaded_specs.key?("turbo-rails")
      config.include Matchers, type: :request
      config.include Matchers, type: :controller
      config.include Helpers, type: :request
      config.include Helpers, type: :controller
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
