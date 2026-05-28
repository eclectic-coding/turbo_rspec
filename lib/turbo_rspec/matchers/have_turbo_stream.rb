# frozen_string_literal: true

require "nokogiri"

module TurboRspec
  module Matchers
    class HaveTurboStream
      def initialize
        @action = nil
        @target = nil
        @target_all = nil
        @content = nil
        @partial = nil
      end

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

      def matches?(response_or_body)
        @body = extract_body(response_or_body)
        @streams = parse_streams(@body)
        @streams.any? { |stream| stream_matches?(stream) }
      end

      def does_not_match?(response_or_body)
        !matches?(response_or_body)
      end

      def failure_message
        "expected response to contain a turbo stream#{constraint_description}\n#{found_streams_message}"
      end

      def failure_message_when_negated
        "expected response not to contain a turbo stream#{constraint_description}"
      end

      def description
        "have turbo stream#{constraint_description}"
      end

      private

      def extract_body(response_or_body)
        if response_or_body.respond_to?(:body)
          response_or_body.body
        else
          response_or_body.to_s
        end
      end

      def parse_streams(body)
        Nokogiri::HTML5.fragment(body).css("turbo-stream")
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

      def constraint_description
        parts = []
        parts << " with action #{@action.inspect}" if @action
        parts << " targeting #{@target.inspect}" if @target
        parts << " targeting all #{@target_all.inspect}" if @target_all
        parts << " with content #{@content.inspect}" if @content
        parts << " rendering #{@partial.inspect}" if @partial
        parts.join
      end

      def found_streams_message
        return "but no turbo streams were found in the response" if @streams.empty?

        lines = ["found #{@streams.size} turbo stream(s):"]
        @streams.each_with_index do |s, i|
          content_preview = s.text.strip.slice(0, 50)
          content_preview = content_preview.empty? ? "(empty)" : content_preview.inspect
          lines << "  #{i + 1}. action=#{s["action"].inspect} target=#{s["target"].inspect} content=#{content_preview}"
        end

        closest = closest_match
        lines << ""
        lines << "closest match (#{count_matching_constraints(closest)}/#{constraint_count} constraint(s) matched):"
        lines.concat(constraint_diff(closest))

        lines.join("\n")
      end

      def closest_match
        @streams.max_by { |s| count_matching_constraints(s) }
      end

      def count_matching_constraints(stream)
        count = 0
        count += 1 if !@action.nil? && matches_action?(stream)
        count += 1 if !@target.nil? && matches_target?(stream)
        count += 1 if !@target_all.nil? && matches_target_all?(stream)
        count += 1 if !@content.nil? && matches_content?(stream)
        count += 1 if !@partial.nil? && matches_partial?(stream)
        count
      end

      def constraint_count
        [@action, @target, @target_all, @content, @partial].count { |c| !c.nil? }
      end

      def constraint_diff(stream)
        lines = []
        lines << "  #{matches_action?(stream) ? "✓" : "✗"} action:   expected #{@action.inspect}, got #{stream["action"].inspect}" if @action
        lines << "  #{matches_target?(stream) ? "✓" : "✗"} target:   expected #{@target.inspect}, got #{stream["target"].inspect}" if @target
        lines << "  #{matches_target_all?(stream) ? "✓" : "✗"} targets:  expected #{@target_all.inspect}, got #{stream["targets"].inspect}" if @target_all
        lines << "  #{matches_content?(stream) ? "✓" : "✗"} content:  expected to include #{@content.inspect}, got #{stream.text.strip.slice(0, 50).inspect}" if @content
        lines << "  #{matches_partial?(stream) ? "✓" : "✗"} rendering: expected to include #{@partial.inspect}" if @partial
        lines
      end
    end
  end
end
