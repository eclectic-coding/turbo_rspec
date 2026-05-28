# frozen_string_literal: true

require "nokogiri"

module TurboRspec
  module Matchers
    class HaveTurboFrame
      def initialize
        @id = nil
        @content = nil
        @partial = nil
      end

      def with_id(id)
        @id = id.to_s
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
        @frames = parse_frames(@body)
        @frames.any? { |frame| frame_matches?(frame) }
      end

      def does_not_match?(response_or_body)
        !matches?(response_or_body)
      end

      def failure_message
        "expected response to contain a turbo frame#{constraint_description}\n#{found_frames_message}"
      end

      def failure_message_when_negated
        "expected response not to contain a turbo frame#{constraint_description}"
      end

      def description
        "have turbo frame#{constraint_description}"
      end

      private

      def extract_body(response_or_body)
        if response_or_body.respond_to?(:body)
          response_or_body.body
        else
          response_or_body.to_s
        end
      end

      def parse_frames(body)
        Nokogiri::HTML5.fragment(body).css("turbo-frame")
      rescue
        Nokogiri::HTML.fragment(body).css("turbo-frame")
      end

      def frame_matches?(frame)
        matches_id?(frame) &&
          matches_content?(frame) &&
          matches_partial?(frame)
      end

      def matches_id?(frame)
        @id.nil? || frame["id"] == @id
      end

      def matches_content?(frame)
        return true if @content.nil?
        frame.text.include?(@content)
      end

      def matches_partial?(frame)
        return true if @partial.nil?
        frame.to_html.include?(@partial)
      end

      def constraint_description
        parts = []
        parts << " with id #{@id.inspect}" if @id
        parts << " with content #{@content.inspect}" if @content
        parts << " rendering #{@partial.inspect}" if @partial
        parts.join
      end

      def found_frames_message
        if @frames.empty?
          "but no turbo frames were found in the response"
        else
          ids = @frames.map { |f| "  <turbo-frame id=#{f["id"].inspect}>" }
          "found turbo frames:\n#{ids.join("\n")}"
        end
      end
    end
  end
end
