# frozen_string_literal: true

require_relative "matchers/have_broadcasted_turbo_stream_to"
require_relative "matchers/have_turbo_frame"
require_relative "matchers/have_turbo_stream"
require_relative "matchers/have_turbo_streams"

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
  end
end
