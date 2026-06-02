# frozen_string_literal: true

module TurboRspec
  module Capybara
    module Matchers
      # Capybara matcher asserting that an element with the given Stimulus
      # controller is present on the page (+data-controller+ contains the name
      # as a space-separated token).
      #
      # @example
      #   expect(page).to have_stimulus_controller("hello")
      #   expect(page).not_to have_stimulus_controller("missing")
      class HaveStimulusController
        def initialize(controller_name)
          @controller_name = controller_name.to_s
        end

        def matches?(page_or_node)
          page_or_node.has_css?(selector, wait: 0)
        end

        def does_not_match?(page_or_node)
          page_or_node.has_no_css?(selector, wait: 0)
        end

        def failure_message
          "expected page to have Stimulus controller #{@controller_name.inspect}"
        end

        def failure_message_when_negated
          "expected page not to have Stimulus controller #{@controller_name.inspect}"
        end

        def description
          "have Stimulus controller #{@controller_name.inspect}"
        end

        private

        def selector
          "[data-controller~='#{@controller_name}']"
        end
      end
    end
  end
end
