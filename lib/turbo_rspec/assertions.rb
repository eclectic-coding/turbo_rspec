# frozen_string_literal: true

require_relative "matchers/have_broadcasted_turbo_stream_to"
require_relative "matchers/have_turbo_frame"
require_relative "matchers/have_turbo_stream"

module TurboRspec
  # Minitest-compatible assertions. Include in your test class:
  #
  #   class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  #     include TurboRspec::Assertions
  #   end
  #
  # No RSpec dependency required.
  module Assertions
    # Assert that a block broadcasts a +<turbo-stream>+ to the given stream.
    # Requires ActionCable's test adapter.
    #
    # @param stream [String] the stream name
    # @param action [Symbol, String, nil] optional action constraint
    # @param target [String, nil] optional target constraint
    # @param targets [String, nil] optional targets (CSS selector) constraint
    # @param content [String, nil] optional content constraint
    # @param partial [String, nil] optional partial path constraint
    # @param message [String, nil] optional custom failure message
    def assert_broadcasted_turbo_stream_to(stream, action: nil, target: nil, targets: nil, content: nil, partial: nil, message: nil, &block)
      matcher = build_broadcast_matcher(stream, action: action, target: target, targets: targets, content: content, partial: partial)
      assert matcher.matches?(block), message || matcher.failure_message
    end

    # Assert that a block does NOT broadcast a +<turbo-stream>+ to the given stream.
    # Requires ActionCable's test adapter.
    #
    # @param stream [String] the stream name
    def refute_broadcasted_turbo_stream_to(stream, action: nil, target: nil, targets: nil, content: nil, partial: nil, message: nil, &block)
      matcher = build_broadcast_matcher(stream, action: action, target: target, targets: targets, content: content, partial: partial)
      assert matcher.does_not_match?(block), message || matcher.failure_message_when_negated
    end

    def assert_turbo_stream(response_or_body, action: nil, target: nil, targets: nil, content: nil, partial: nil, message: nil)
      matcher = build_stream_matcher(action: action, target: target, targets: targets, content: content, partial: partial)
      assert matcher.matches?(response_or_body), message || matcher.failure_message
    end

    def refute_turbo_stream(response_or_body, action: nil, target: nil, targets: nil, content: nil, partial: nil, message: nil)
      matcher = build_stream_matcher(action: action, target: target, targets: targets, content: content, partial: partial)
      assert matcher.does_not_match?(response_or_body), message || matcher.failure_message_when_negated
    end

    def assert_turbo_frame(response_or_body, id: nil, content: nil, partial: nil, message: nil)
      matcher = build_frame_matcher(id: id, content: content, partial: partial)
      assert matcher.matches?(response_or_body), message || matcher.failure_message
    end

    def refute_turbo_frame(response_or_body, id: nil, content: nil, partial: nil, message: nil)
      matcher = build_frame_matcher(id: id, content: content, partial: partial)
      assert matcher.does_not_match?(response_or_body), message || matcher.failure_message_when_negated
    end

    private

    def build_broadcast_matcher(stream, action:, target:, targets:, content:, partial:)
      matcher = Matchers::HaveBroadcastedTurboStreamTo.new(stream)
      matcher.with_action(action) if action
      matcher.targeting(target) if target
      matcher.targeting_all(targets) if targets
      matcher.with_content(content) if content
      matcher.rendering(partial) if partial
      matcher
    end

    def build_stream_matcher(action:, target:, targets:, content:, partial:)
      matcher = Matchers::HaveTurboStream.new
      matcher.with_action(action) if action
      matcher.targeting(target) if target
      matcher.targeting_all(targets) if targets
      matcher.with_content(content) if content
      matcher.rendering(partial) if partial
      matcher
    end

    def build_frame_matcher(id:, content:, partial:)
      matcher = Matchers::HaveTurboFrame.new
      matcher.with_id(id) if id
      matcher.with_content(content) if content
      matcher.rendering(partial) if partial
      matcher
    end
  end
end
