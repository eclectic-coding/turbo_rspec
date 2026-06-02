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
        @attributes = {}
        @children_only = false
        @expected_count = nil
        @count_type = :at_least
      end

      # Stream constraints (mirrors HaveTurboStream)

      def with_action(action)
        action_str = action.to_s
        unless TurboRspec.known_actions.include?(action_str)
          raise ArgumentError, "Unknown Turbo stream action #{action_str.inspect}. " \
            "Register custom actions with TurboRspec.register_action(:#{action_str})."
        end
        @action = action_str
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

      def with_attributes(attrs)
        @attributes = attrs.transform_keys(&:to_s).transform_values(&:to_s)
        self
      end

      def children_only
        @children_only = true
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
        @new_broadcasts = snapshot - before
        @all_streams = parse_all_streams(@new_broadcasts)
        @matching = @new_broadcasts.select { |msg| message_matches?(msg) }
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
          matches_partial?(stream) &&
          matches_attributes?(stream) &&
          matches_children_only?(stream)
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

      def matches_attributes?(stream)
        return true if @attributes.empty?
        @attributes.all? { |k, v| stream[k] == v }
      end

      def matches_children_only?(stream)
        return true unless @children_only
        !stream["children-only"].nil?
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
        parts << " with attributes #{@attributes.inspect}" if @attributes.any?
        parts << " children only" if @children_only
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
        if @matching.size > 0
          "found #{@matching.size} matching broadcast(s)"
        elsif @all_streams.empty?
          "but no broadcasts were made to #{stream_name.inspect}"
        else
          no_match_message
        end
      end

      def no_match_message
        lines = ["found #{@all_streams.size} stream(s) broadcast to #{stream_name.inspect}:"]
        @all_streams.each_with_index do |s, i|
          content_preview = s.text.strip.slice(0, 50)
          content_preview = content_preview.empty? ? "(empty)" : content_preview.inspect
          lines << "  #{i + 1}. action=#{s["action"].inspect} target=#{s["target"].inspect} content=#{content_preview}"
        end

        # :nocov:
        if constraint_count > 0
          # :nocov:
          closest = @all_streams.max_by { |s| count_matching_constraints(s) }
          lines << ""
          lines << "closest match (#{count_matching_constraints(closest)}/#{constraint_count} constraint(s) matched):"
          lines.concat(constraint_diff(closest))
        end

        lines.join("\n")
      end

      def parse_all_streams(broadcasts)
        broadcasts.flat_map do |msg|
          html = JSON.parse(msg)
          Nokogiri::HTML5.fragment(html).css("turbo-stream").to_a
        rescue JSON::ParserError
          []
        end
      end

      def count_matching_constraints(stream)
        count = 0
        count += 1 if !@action.nil? && matches_action?(stream)
        count += 1 if !@target.nil? && matches_target?(stream)
        count += 1 if !@target_all.nil? && matches_target_all?(stream)
        count += 1 if !@content.nil? && matches_content?(stream)
        count += 1 if !@partial.nil? && matches_partial?(stream)
        count += 1 if @attributes.any? && matches_attributes?(stream)
        count += 1 if @children_only && matches_children_only?(stream)
        count
      end

      def constraint_count
        [@action, @target, @target_all, @content, @partial].count { |c| !c.nil? } +
          (@attributes.any? ? 1 : 0) +
          (@children_only ? 1 : 0)
      end

      def constraint_diff(stream)
        lines = []
        lines << "  #{matches_action?(stream) ? "✓" : "✗"} action:   expected #{@action.inspect}, got #{stream["action"].inspect}" if @action
        lines << "  #{matches_target?(stream) ? "✓" : "✗"} target:   expected #{@target.inspect}, got #{stream["target"].inspect}" if @target
        lines << "  #{matches_target_all?(stream) ? "✓" : "✗"} targets:  expected #{@target_all.inspect}, got #{stream["targets"].inspect}" if @target_all
        lines << "  #{matches_content?(stream) ? "✓" : "✗"} content:  expected to include #{@content.inspect}, got #{stream.text.strip.slice(0, 50).inspect}" if @content
        lines << "  #{matches_partial?(stream) ? "✓" : "✗"} rendering: expected to include #{@partial.inspect}" if @partial
        @attributes.each do |k, v|
          actual = stream[k]
          lines << "  #{(actual == v) ? "✓" : "✗"} attr[#{k}]: expected #{v.inspect}, got #{actual.inspect}"
        end
        lines << "  #{matches_children_only?(stream) ? "✓" : "✗"} children-only: expected attribute to be present" if @children_only
        lines
      end
    end
  end
end
