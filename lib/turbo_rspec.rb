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

  # Built-in Turbo stream action names.
  BUILTIN_ACTIONS = %w[append prepend replace update remove before after refresh morph].freeze

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

    # Registers one or more custom Turbo stream action names so that
    # +have_turbo_stream.with_action(:name)+ does not raise +ArgumentError+.
    #
    # @param actions [Array<Symbol, String>]
    # @return [void]
    # @example
    #   TurboRspec.register_action(:sparkle, :highlight)
    def register_action(*actions)
      configuration.custom_actions |= actions.map(&:to_s)
    end

    # Returns all known stream action names (built-in + registered custom).
    #
    # @return [Array<String>]
    def known_actions
      BUILTIN_ACTIONS + configuration.custom_actions
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
if defined?(RSpec) && RSpec.respond_to?(:configure)
  RSpec.configure { |config| TurboRspec.install_rspec_integration(config) }
end
# :nocov:
