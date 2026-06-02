# frozen_string_literal: true

module RuboCop
  module Cop
    module TurboRspec
      # Flags request specs that assert turbo stream content by matching against
      # +response.body+ as a raw string. Use +have_turbo_stream+ instead.
      #
      # @example Bad — string matching on response.body
      #   expect(response.body).to include("<turbo-stream")
      #   expect(response.body).to match(/turbo-stream/)
      #
      # @example Good
      #   expect(response).to have_turbo_stream
      #   expect(response).to have_turbo_stream.with_action(:append).targeting("list")
      class UseHaveTurboStream < Base
        MSG = "Use `expect(response).to have_turbo_stream` instead of " \
              "asserting on `response.body` directly."

        RESTRICT_ON_SEND = %i[to not_to].freeze

        # Matches: expect(response.body).to <matcher>(...)
        def_node_matcher :response_body_expectation?, <<~PATTERN
          (send
            (send nil? :expect
              (send (send nil? :response) :body))
            {:to :not_to}
            ...)
        PATTERN

        def on_send(node)
          return unless response_body_expectation?(node)
          return unless turbo_stream_related?(node)

          add_offense(node)
        end

        private

        def turbo_stream_related?(node)
          node.descendants.any? do |n|
            (n.str_type? && turbo_stream_string?(n.value)) ||
              (n.regexp_type? && turbo_stream_string?(n.loc.expression.source))
          end
        end

        def turbo_stream_string?(str)
          str.include?("turbo-stream") || str.include?("turbo_stream")
        end
      end
    end
  end
end
