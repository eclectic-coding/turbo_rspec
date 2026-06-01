# frozen_string_literal: true

require "nokogiri"

module TurboRspec
  module Matchers
    # RSpec matcher for asserting that a response body contains a
    # +<turbo-stream>+ element. Constraints are applied via a fluent chain;
    # all specified constraints must match the *same* stream element.
    #
    # @example Basic usage
    #   expect(response).to have_turbo_stream
    #
    # @example Chained constraints
    #   expect(response).to have_turbo_stream
    #     .with_action(:append)
    #     .targeting("messages")
    #     .with_content("Hello")
    #
    # @example Negation
    #   expect(response).not_to have_turbo_stream.with_action(:replace)
    #
    # @see TurboRspec::Matchers#have_turbo_stream
    class HaveTurboStream
      def initialize
        @action = nil
        @target = nil
        @target_all = nil
        @content = nil
        @partial = nil
        @attributes = {}
        @children_only = false
        @expected_count = nil
        @count_type = :at_least
        @matching_count = 0
      end

      # Constrains the match to streams with the given action.
      # @param action [Symbol, String] e.g. +:append+, +:replace+, +:remove+, +:refresh+, +:morph+
      # @raise [ArgumentError] if the action is not a known built-in or registered custom action
      # @return [self]
      def with_action(action)
        action_str = action.to_s
        unless TurboRspec.known_actions.include?(action_str)
          raise ArgumentError, "Unknown Turbo stream action #{action_str.inspect}. " \
            "Register custom actions with TurboRspec.register_action(:#{action_str})."
        end
        @action = action_str
        self
      end

      # Constrains the match to streams targeting a specific DOM id.
      # @param dom_id [String]
      # @return [self]
      def targeting(dom_id)
        @target = dom_id.to_s
        self
      end

      # Constrains the match to streams targeting a CSS selector (the +targets+ attribute).
      # @param selector [String] e.g. +".message-item"+
      # @return [self]
      def targeting_all(selector)
        @target_all = selector.to_s
        self
      end

      # Constrains the match to streams whose template content includes the given text.
      # @param text [String]
      # @return [self]
      def with_content(text)
        @content = text.to_s
        self
      end

      # Constrains the match to streams whose rendered HTML includes the given partial path.
      # @param partial [String] e.g. +"messages/_message"+
      # @return [self]
      def rendering(partial)
        @partial = partial.to_s
        self
      end

      # Constrains the match to streams that have all of the given HTML attributes.
      # Keys and values are compared as strings.
      # @param attrs [Hash]
      # @return [self]
      # @example
      #   expect(response).to have_turbo_stream.with_attributes("data-controller" => "messages")
      def with_attributes(attrs)
        @attributes = attrs.transform_keys(&:to_s).transform_values(&:to_s)
        self
      end

      # Constrains the match to morph streams with the +children-only+ attribute set.
      # @return [self]
      # @example
      #   expect(response).to have_turbo_stream.with_action(:morph).children_only
      def children_only
        @children_only = true
        self
      end

      # Asserts exactly one matching stream.
      # @return [self]
      def once
        exactly(1)
      end

      # Asserts exactly two matching streams.
      # @return [self]
      def twice
        exactly(2)
      end

      # Asserts exactly +n+ matching streams.
      # @param n [Integer]
      # @return [self]
      def exactly(n)
        @expected_count = n
        @count_type = :exactly
        self
      end

      # Asserts at least +n+ matching streams.
      # @param n [Integer]
      # @return [self]
      def at_least(n)
        @expected_count = n
        @count_type = :at_least
        self
      end

      # Asserts at most +n+ matching streams.
      # @param n [Integer]
      # @return [self]
      def at_most(n)
        @expected_count = n
        @count_type = :at_most
        self
      end

      # Fluent terminator so +.exactly(2).times+ reads naturally.
      # @return [self]
      def times
        self
      end

      # @param response_or_body [#body, String]
      # @return [Boolean]
      def matches?(response_or_body)
        @body = extract_body(response_or_body)
        @streams = parse_streams(@body)
        @matching_count = @streams.count { |stream| stream_matches?(stream) }
        count_matches?(@matching_count)
      end

      # @param response_or_body [#body, String]
      # @return [Boolean]
      def does_not_match?(response_or_body)
        !matches?(response_or_body)
      end

      # @return [String]
      def failure_message
        "expected response to contain a turbo stream#{constraint_description}#{count_description}\n#{found_streams_message}"
      end

      # @return [String]
      def failure_message_when_negated
        "expected response not to contain a turbo stream#{constraint_description}#{count_description}"
      end

      # @return [String]
      def description
        "have turbo stream#{constraint_description}#{count_description}"
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
        return "" if @expected_count.nil?
        # :nocov:
        case @count_type
        # :nocov:
        when :exactly then " exactly #{@expected_count} time(s)"
        when :at_least then " at least #{@expected_count} time(s)"
        when :at_most then " at most #{@expected_count} time(s)"
        end
      end

      def found_streams_message
        return "but no turbo streams were found in the response" if @streams.empty?

        lines = ["found #{@streams.size} turbo stream(s):"]
        @streams.each_with_index do |s, i|
          content_preview = s.text.strip.slice(0, 50)
          content_preview = content_preview.empty? ? "(empty)" : content_preview.inspect
          lines << "  #{i + 1}. action=#{s["action"].inspect} target=#{s["target"].inspect} content=#{content_preview}"
        end

        if @expected_count
          lines << ""
          lines << "#{@matching_count} of #{@streams.size} stream(s) matched the constraints"
        else
          closest = closest_match
          lines << ""
          lines << "closest match (#{count_matching_constraints(closest)}/#{constraint_count} constraint(s) matched):"
          lines.concat(constraint_diff(closest))
        end

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
          lines << "  #{actual == v ? "✓" : "✗"} attr[#{k}]: expected #{v.inspect}, got #{actual.inspect}"
        end
        lines << "  #{matches_children_only?(stream) ? "✓" : "✗"} children-only: expected attribute to be present" if @children_only
        lines
      end
    end
  end
end
