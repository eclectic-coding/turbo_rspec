# frozen_string_literal: true

require_relative "matchers/have_turbo_frame"
require_relative "matchers/have_turbo_stream_tag"
require_relative "matchers/have_stimulus_controller"
require_relative "matchers/have_stimulus_action"
require_relative "matchers/have_stimulus_target"

module TurboRspec
  module Capybara
    module Matchers
      def have_turbo_frame(id)
        HaveTurboFrame.new(id)
      end

      def have_turbo_stream_tag(signed_stream_name = nil)
        HaveTurboStreamTag.new(signed_stream_name: signed_stream_name)
      end

      def have_stimulus_controller(controller_name)
        HaveStimulusController.new(controller_name)
      end

      def have_stimulus_action(action_descriptor)
        HaveStimulusAction.new(action_descriptor)
      end

      def have_stimulus_target(controller_name, target_name)
        HaveStimulusTarget.new(controller_name, target_name)
      end

      # simplecov:disable
      def within_turbo_frame(id, &block)
        page.within("turbo-frame##{id}", &block)
      end
      # simplecov:enable
    end
  end
end
