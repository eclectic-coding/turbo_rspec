# frozen_string_literal: true

module TurboRspec
  # Holds global configuration for TurboRspec.
  #
  # @see TurboRspec.configure
  class Configuration
    # @!attribute [rw] auto_include
    #   When +true+ (default), matchers are automatically included into
    #   +type: :request+ and +type: :controller+ example groups when
    #   +turbo-rails+ is present, and Capybara matchers into +type: :system+
    #   and +type: :feature+ when +capybara+ is also present.
    #   @return [Boolean]
    attr_accessor :auto_include

    # @!attribute [rw] custom_actions
    #   Additional stream action names registered via +TurboRspec.register_action+.
    #   @return [Array<String>]
    attr_accessor :custom_actions

    # @!attribute [rw] snapshot_dir
    #   Directory where turbo stream snapshots are stored.
    #   Defaults to +"spec/snapshots/turbo"+.
    #   @return [String]
    attr_accessor :snapshot_dir

    def initialize
      @auto_include = true
      @custom_actions = []
      @snapshot_dir = "spec/snapshots/turbo"
    end
  end
end
