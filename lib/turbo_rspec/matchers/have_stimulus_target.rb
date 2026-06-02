# frozen_string_literal: true

require "nokogiri"

module TurboRspec
  module Matchers
    # RSpec matcher for asserting that a response body contains an element with
    # the given Stimulus target (+data-{controller}-target+ contains the target
    # name as a space-separated token).
    #
    # @example
    #   expect(response).to have_stimulus_target("hello", "name")
    #   expect(response).not_to have_stimulus_target("hello", "missing")
    class HaveStimulusTarget
      def initialize(controller_name, target_name)
        @controller_name = controller_name.to_s
        @target_name = target_name.to_s
      end

      # @param response_or_body [#body, String]
      # @return [Boolean]
      def matches?(response_or_body)
        @body = extract_body(response_or_body)
        Nokogiri::HTML5.fragment(@body).css("[data-#{@controller_name}-target~='#{@target_name}']").any?
      end

      # @param response_or_body [#body, String]
      # @return [Boolean]
      def does_not_match?(response_or_body)
        !matches?(response_or_body)
      end

      # @return [String]
      def failure_message
        "expected response to have Stimulus target #{@target_name.inspect} for controller #{@controller_name.inspect}"
      end

      # @return [String]
      def failure_message_when_negated
        "expected response not to have Stimulus target #{@target_name.inspect} for controller #{@controller_name.inspect}"
      end

      # @return [String]
      def description
        "have Stimulus target #{@target_name.inspect} for #{@controller_name.inspect}"
      end

      private

      def extract_body(response_or_body)
        if response_or_body.respond_to?(:body)
          response_or_body.body
        else
          response_or_body.to_s
        end
      end
    end
  end
end
