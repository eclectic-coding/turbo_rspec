# frozen_string_literal: true

require "rails/generators"

module TurboRspec
  module Generators
    # Rails generator that scaffolds a spec/support/turbo_rspec.rb file
    # with sensible defaults for TurboRspec configuration.
    #
    # @example
    #   rails generate turbo_rspec:install
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates a spec/support/turbo_rspec.rb configuration file"

      def create_support_file
        template "turbo_rspec.rb", "spec/support/turbo_rspec.rb"
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
