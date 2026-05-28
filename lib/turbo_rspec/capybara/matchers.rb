# frozen_string_literal: true

require_relative "matchers/have_turbo_frame"
require_relative "matchers/have_turbo_stream_tag"

module TurboRspec
  module Capybara
    module Matchers
      def have_turbo_frame(id)
        HaveTurboFrame.new(id)
      end

      def have_turbo_stream_tag(signed_stream_name = nil)
        HaveTurboStreamTag.new(signed_stream_name: signed_stream_name)
      end

      def within_turbo_frame(id, &block)
        page.within("turbo-frame##{id}", &block)
      end
    end
  end
end
