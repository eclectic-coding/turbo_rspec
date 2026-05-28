# frozen_string_literal: true

module TurboRspec
  class Configuration
    attr_accessor :auto_include

    def initialize
      @auto_include = true
    end
  end
end
