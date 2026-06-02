# frozen_string_literal: true

module TurboRspec
  module Capybara
    module Matchers
      # Capybara matcher asserting that an element with the given Stimulus
      # target is present on the page. Checks +data-{controller}-target+
      # contains the target name as a space-separated token.
      #
      # @example
      #   expect(page).to have_stimulus_target("hello", "name")
      #   expect(page).not_to have_stimulus_target("hello", "missing")
      class HaveStimulusTarget
        def initialize(controller_name, target_name)
          @controller_name = controller_name.to_s
          @target_name = target_name.to_s
        end

        def matches?(page_or_node)
          page_or_node.has_css?(selector, wait: 0)
        end

        def does_not_match?(page_or_node)
          page_or_node.has_no_css?(selector, wait: 0)
        end

        def failure_message
          "expected page to have Stimulus target #{@target_name.inspect} for controller #{@controller_name.inspect}"
        end

        def failure_message_when_negated
          "expected page not to have Stimulus target #{@target_name.inspect} for controller #{@controller_name.inspect}"
        end

        def description
          "have Stimulus target #{@target_name.inspect} for #{@controller_name.inspect}"
        end

        private

        def selector
          "[data-#{@controller_name}-target~='#{@target_name}']"
        end
      end
    end
  end
end