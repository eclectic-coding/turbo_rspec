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
        return "but no turbo frames were found in the response" if @frames.empty?

        lines = ["found #{@frames.size} turbo frame(s):"]
        @frames.each_with_index do |f, i|
          content_preview = f.text.strip.slice(0, 50)
          content_preview = content_preview.empty? ? "(empty)" : content_preview.inspect
          lines << "  #{i + 1}. id=#{f["id"].inspect} content=#{content_preview}"
        end

        closest = closest_match
        if closest
          lines << ""
          lines << "closest match (#{count_matching_constraints(closest)}/#{constraint_count} constraint(s) matched):"
          lines.concat(constraint_diff(closest))
        end

        lines.join("\n")
      end

      def closest_match
        return nil if @frames.empty?
        @frames.max_by { |f| count_matching_constraints(f) }
      end

      def count_matching_constraints(frame)
        count = 0
        count += 1 if !@id.nil? && matches_id?(frame)
        count += 1 if !@content.nil? && matches_content?(frame)
        count += 1 if !@partial.nil? && matches_partial?(frame)
        count
      end

      def constraint_count
        [@id, @content, @partial].count { |c| !c.nil? }
      end

      def constraint_diff(frame)
        lines = []
        lines << "  #{matches_id?(frame) ? "✓" : "✗"} id:      expected #{@id.inspect}, got #{frame["id"].inspect}" if @id
        lines << "  #{matches_content?(frame) ? "✓" : "✗"} content: expected to include #{@content.inspect}, got #{frame.text.strip.slice(0, 50).inspect}" if @content
        lines << "  #{matches_partial?(frame) ? "✓" : "✗"} rendering: expected to include #{@partial.inspect}" if @partial
        lines
      end
    end
  end
end
