# frozen_string_literal: true

require "nokogiri"

module TurboRspec
  module Matchers
    class HaveTurboStreams
      def initialize(expected_streams)
        @expected_streams = expected_streams
      end

      def matches?(response_or_body)
        @body = extract_body(response_or_body)
        @found = parse_streams(@body)
        @unmatched = @expected_streams.reject { |expected| any_stream_matches?(expected) }
        @unmatched.empty?
      end

      def does_not_match?(response_or_body)
        !matches?(response_or_body)
      end

      def failure_message
        descriptions = @unmatched.map { |m| "  #{m.description}" }.join("\n")
        "expected response to contain all turbo streams, but missing:\n#{descriptions}\n\n" \
          "found streams:\n#{found_streams_summary}"
      end

      def failure_message_when_negated
        "expected response not to contain all of the specified turbo streams"
      end

      def description
        "have turbo streams: #{@expected_streams.map(&:description).join(", ")}"
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

      def any_stream_matches?(matcher)
        @found.any? { |stream| stream_matches_matcher?(stream, matcher) }
      end

      def stream_matches_matcher?(stream, matcher)
        matcher.send(:stream_matches?, stream)
      end

      def found_streams_summary
        return "  (none)" if @found.empty?
        @found.map { |s| "  <turbo-stream action=#{s["action"].inspect} target=#{s["target"].inspect}>" }.join("\n")
      end
    end
  end
end
