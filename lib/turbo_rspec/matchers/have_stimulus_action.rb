# frozen_string_literal: true

require "nokogiri"

module TurboRspec
  module Matchers
    # RSpec matcher for asserting that a response body contains an element with
    # the given Stimulus action descriptor (+data-action+ contains the descriptor
    # as a space-separated token).
    #
    # Accepts a full descriptor (+click->hello#greet+) or a shorthand without
    # an event (+hello#greet+), which matches any event prefix.
    #
    # @example Full descriptor
    #   expect(response).to have_stimulus_action("click->hello#greet")
    #
    # @example Shorthand (any event)
    #   expect(response).to have_stimulus_action("hello#greet")
    class HaveStimulusAction
      def initialize(action_descriptor)
        @action_descriptor = action_descriptor.to_s
      end

      # @param response_or_body [#body, String]
      # @return [Boolean]
      def matches?(response_or_body)
        @body = extract_body(response_or_body)
        Nokogiri::HTML5.fragment(@body).css(selector).any?
      end

      # @param response_or_body [#body, String]
      # @return [Boolean]
      def does_not_match?(response_or_body)
        !matches?(response_or_body)
      end

      # @return [String]
      def failure_message
        "expected response to have Stimulus action #{@action_descriptor.inspect}"
      end

      # @return [String]
      def failure_message_when_negated
        "expected response not to have Stimulus action #{@action_descriptor.inspect}"
      end

      # @return [String]
      def description
        "have Stimulus action #{@action_descriptor.inspect}"
      end

      private

      def extract_body(response_or_body)
        if response_or_body.respond_to?(:body)
          response_or_body.body
        else
          response_or_body.to_s
        end
      end

      def selector
        if @action_descriptor.include?("->")
          "[data-action~='#{@action_descriptor}']"
        else
          "[data-action*='#{@action_descriptor}']"
        end
      end
    end
  end
end
