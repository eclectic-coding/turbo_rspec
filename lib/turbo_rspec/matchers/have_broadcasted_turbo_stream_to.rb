# frozen_string_literal: true

require "nokogiri"

module TurboRspec
  module Matchers
    class HaveBroadcastedTurboStreamTo
      def initialize(stream_or_object)
        @stream_or_object = stream_or_object
        @action = nil
        @target = nil
        @target_all = nil
        @content = nil
        @partial = nil
        @expected_count = nil
        @count_type = :at_least
      end

      # Stream constraints (mirrors HaveTurboStream)

      def with_action(action)
        @action = action.to_s
        self
      end

      def targeting(dom_id)
        @target = dom_id.to_s
        self
      end

      def targeting_all(selector)
        @target_all = selector.to_s
        self
      end

      def with_content(text)
        @content = text.to_s
        self
      end

      def rendering(partial)
        @partial = partial.to_s
        self
      end

      # Count qualifiers

      def once
        exactly(1)
      end

      def twice
        exactly(2)
      end

      def exactly(n)
        @expected_count = n
        @count_type = :exactly
        self
      end

      def at_least(n)
        @expected_count = n
        @count_type = :at_least
        self
      end

      def at_most(n)
        @expected_count = n
        @count_type = :at_most
        self
      end

      def times
        self
      end

      def supports_block_expectations?
        true
      end

      def matches?(block)
        before = snapshot
        block.call
        @matching = (snapshot - before).select { |msg| message_matches?(msg) }
        count_matches?(@matching.size)
      end

      def does_not_match?(block)
        !matches?(block)
      end

      def failure_message
        "expected block to broadcast a turbo stream to #{stream_name.inspect}#{constraint_description}#{count_description}\n#{found_message}"
      end

      def failure_message_when_negated
        "expected block not to broadcast a turbo stream to #{stream_name.inspect}#{constraint_description}"
      end

      def description
        "broadcast a turbo stream to #{stream_name.inspect}#{constraint_description}"
      end

      private

      def stream_name
        @stream_name ||= if @stream_or_object.respond_to?(:to_str)
          @stream_or_object
        elsif defined?(Turbo::StreamsChannel)
          Turbo::StreamsChannel.broadcasting_for(@stream_or_object)
        else
          @stream_or_object.to_s
        end
      end

      def snapshot
        ActionCable.server.pubsub.broadcasts(stream_name).dup
      end

      def message_matches?(message)
        html = JSON.parse(message)
        streams = Nokogiri::HTML5.fragment(html).css("turbo-stream")
        streams.any? { |stream| stream_matches?(stream) }
      rescue JSON::ParserError
        false
      end

      def stream_matches?(stream)
        matches_action?(stream) &&
          matches_target?(stream) &&
          matches_target_all?(stream) &&
          matches_content?(stream) &&
          matches_partial?(stream)
      end

      def matches_action?(stream)
        @action.nil? || stream["action"] == @action
      end

      def matches_target?(stream)
        @target.nil? || stream["target"] == @target
      end

      def matches_target_all?(stream)
        @target_all.nil? || stream["targets"] == @target_all
      end

      def matches_content?(stream)
        return true if @content.nil?
        stream.text.include?(@content)
      end

      def matches_partial?(stream)
        return true if @partial.nil?
        stream.to_html.include?(@partial)
      end

      def count_matches?(n)
        if @expected_count.nil?
          n >= 1
        else
          # :nocov:
          case @count_type
          # :nocov:
          when :exactly then n == @expected_count
          when :at_least then n >= @expected_count
          when :at_most then n <= @expected_count
          end
        end
      end

      def constraint_description
        parts = []
        parts << " with action #{@action.inspect}" if @action
        parts << " targeting #{@target.inspect}" if @target
        parts << " targeting all #{@target_all.inspect}" if @target_all
        parts << " with content #{@content.inspect}" if @content
        parts << " rendering #{@partial.inspect}" if @partial
        parts.join
      end

      def count_description
        return "" if @expected_count.nil? && @count_type == :at_least
        # :nocov:
        case @count_type
        # :nocov:
        when :exactly then " exactly #{@expected_count} time(s)"
        when :at_least then " at least #{@expected_count} time(s)"
        when :at_most then " at most #{@expected_count} time(s)"
        end
      end

      def found_message
        if @matching.empty?
          "but no matching broadcasts were found"
        else
          "found #{@matching.size} matching broadcast(s)"
        end
      end
    end
  end
end
