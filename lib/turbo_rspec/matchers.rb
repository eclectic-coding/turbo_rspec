# frozen_string_literal: true

require_relative "matchers/have_turbo_stream"

module TurboRspec
  module Matchers
    def have_turbo_stream
      HaveTurboStream.new
    end
  end
end
