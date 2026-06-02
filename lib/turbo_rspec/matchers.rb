# frozen_string_literal: true

require_relative "matchers/have_broadcasted_turbo_stream_to"
require_relative "matchers/have_stimulus_action"
require_relative "matchers/have_stimulus_controller"
require_relative "matchers/have_stimulus_target"
require_relative "matchers/have_turbo_frame"
require_relative "matchers/have_turbo_stream"
require_relative "matchers/have_turbo_streams"
require_relative "matchers/match_turbo_stream_snapshot"

module TurboRspec
  # RSpec matchers for Turbo Stream and Turbo Frame assertions.
  # Auto-included in +type: :request+ and +type: :controller+ example groups.
  # Include explicitly for other contexts:
  #
  #   RSpec.configure do |config|
  #     config.include TurboRspec::Matchers
  #   end
  module Matchers
    # Assert that a block broadcasts a +<turbo-stream>+ to the given stream.
    # @param stream_or_object [String, Object] stream name or streamable object
    # @return [HaveBroadcastedTurboStreamTo]
    def have_broadcasted_turbo_stream_to(stream_or_object)
      HaveBroadcastedTurboStreamTo.new(stream_or_object)
    end

    # @see #have_broadcasted_turbo_stream_to
    alias_method :broadcast_turbo_stream_to, :have_broadcasted_turbo_stream_to

    # Assert that a response body contains a +<turbo-frame>+ element.
    # @return [HaveTurboFrame]
    def have_turbo_frame
      HaveTurboFrame.new
    end

    # Assert that a response body contains a +<turbo-stream>+ element.
    # @return [HaveTurboStream]
    def have_turbo_stream
      HaveTurboStream.new
    end

    # Alias of {#have_turbo_stream} for teams using minitest-style naming.
    # @see #have_turbo_stream
    alias_method :assert_no_turbo_stream, :have_turbo_stream

    # Assert that a response body contains *all* of the given turbo streams.
    # @param matchers [Array<HaveTurboStream>] one or more {#have_turbo_stream} matchers
    # @return [HaveTurboStreams]
    def have_turbo_streams(*matchers)
      HaveTurboStreams.new(matchers)
    end

    # Assert that a response body contains an element with the given Stimulus controller.
    # @param controller_name [String]
    # @return [HaveStimulusController]
    def have_stimulus_controller(controller_name)
      HaveStimulusController.new(controller_name)
    end

    # Assert that a response body contains an element with the given Stimulus action.
    # @param action_descriptor [String]
    # @return [HaveStimulusAction]
    def have_stimulus_action(action_descriptor)
      HaveStimulusAction.new(action_descriptor)
    end

    # Assert that a response body contains an element with the given Stimulus target.
    # @param controller_name [String]
    # @param target_name [String]
    # @return [HaveStimulusTarget]
    def have_stimulus_target(controller_name, target_name)
      HaveStimulusTarget.new(controller_name, target_name)
    end

    # Assert that a response body matches a stored turbo stream snapshot.
    # Creates the snapshot on the first run; diffs against it on subsequent runs.
    # Set +UPDATE_TURBO_SNAPSHOTS=1+ to overwrite an existing snapshot.
    # @param name [String] snapshot name, used as the file path within +snapshot_dir+
    # @return [MatchTurboStreamSnapshot]
    def match_turbo_stream_snapshot(name)
      MatchTurboStreamSnapshot.new(name)
    end
  end
end
