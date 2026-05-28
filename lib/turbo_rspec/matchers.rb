# frozen_string_literal: true

require_relative "matchers/have_broadcasted_turbo_stream_to"
require_relative "matchers/have_turbo_frame"
require_relative "matchers/have_turbo_stream"
require_relative "matchers/have_turbo_streams"

module TurboRspec
  module Matchers
    def have_broadcasted_turbo_stream_to(stream_or_object)
      HaveBroadcastedTurboStreamTo.new(stream_or_object)
    end

    alias_method :broadcast_turbo_stream_to, :have_broadcasted_turbo_stream_to

    def have_turbo_frame
      HaveTurboFrame.new
    end

    def have_turbo_stream
      HaveTurboStream.new
    end

    alias_method :assert_no_turbo_stream, :have_turbo_stream

    def have_turbo_streams(*matchers)
      HaveTurboStreams.new(matchers)
    end
  end
end
