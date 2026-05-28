# frozen_string_literal: true

module TurboRspec
  module Capybara
    module Matchers
      class HaveTurboStreamTag
        def initialize(signed_stream_name: nil)
          @signed_stream_name = signed_stream_name
        end

        def matches?(page_or_node)
          selector = build_selector
          page_or_node.has_css?(selector, wait: 0)
        end

        def does_not_match?(page_or_node)
          selector = build_selector
          page_or_node.has_no_css?(selector, wait: 0)
        end

        def failure_message
          "expected page to have a turbo-stream-source element#{stream_description}"
        end

        def failure_message_when_negated
          "expected page not to have a turbo-stream-source element#{stream_description}"
        end

        def description
          "have turbo-stream-source#{stream_description}"
        end

        private

        def build_selector
          if @signed_stream_name
            "turbo-stream-source[src*=\"#{@signed_stream_name}\"]"
          else
            "turbo-stream-source"
          end
        end

        def stream_description
          @signed_stream_name ? " for #{@signed_stream_name.inspect}" : ""
        end
      end
    end
  end
end
