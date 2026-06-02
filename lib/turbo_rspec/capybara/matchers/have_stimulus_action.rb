# frozen_string_literal: true

module TurboRspec
  module Capybara
    module Matchers
      # Capybara matcher asserting that an element with the given Stimulus
      # action descriptor is present on the page (+data-action+ contains the
      # descriptor as a space-separated token).
      #
      # Accepts either a full descriptor (+click->hello#greet+) or a shorthand
      # without an event (+hello#greet+), which matches any event prefix.
      #
      # @example Full descriptor
      #   expect(page).to have_stimulus_action("click->hello#greet")
      #
      # @example Shorthand (any event)
      #   expect(page).to have_stimulus_action("hello#greet")
      class HaveStimulusAction
        def initialize(action_descriptor)
          @action_descriptor = action_descriptor.to_s
        end

        def matches?(page_or_node)
          page_or_node.has_css?(selector, wait: 0)
        end

        def does_not_match?(page_or_node)
          page_or_node.has_no_css?(selector, wait: 0)
        end

        def failure_message
          "expected page to have Stimulus action #{@action_descriptor.inspect}"
        end

        def failure_message_when_negated
          "expected page not to have Stimulus action #{@action_descriptor.inspect}"
        end

        def description
          "have Stimulus action #{@action_descriptor.inspect}"
        end

        private

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
end
