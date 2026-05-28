# frozen_string_literal: true

module TurboRspec
  module Capybara
    module Matchers
      class HaveTurboFrame
        def initialize(id)
          @id = id.to_s
          @content = nil
          @loaded = false
        end

        def with_content(text)
          @content = text.to_s
          self
        end

        def loaded
          @loaded = true
          self
        end

        def matches?(page_or_node)
          @node = find_frame(page_or_node)
          return false unless @node
          return false if @loaded && !@node[:complete]
          return false if @content && !@node.has_content?(@content, wait: 0)
          true
        rescue ::Capybara::ElementNotFound
          @node = nil
          false
        end

        def does_not_match?(page_or_node)
          !matches?(page_or_node)
        end

        def failure_message
          if @node.nil?
            "expected page to have turbo-frame##{@id}#{constraint_description} but it was not found"
          elsif @loaded && !@node[:complete]
            "expected turbo-frame##{@id} to be loaded (missing [complete] attribute)"
          else
            "expected turbo-frame##{@id} to have content #{@content.inspect}"
          end
        end

        def failure_message_when_negated
          "expected page not to have turbo-frame##{@id}#{constraint_description}"
        end

        def description
          "have turbo-frame##{@id}#{constraint_description}"
        end

        private

        def find_frame(page_or_node)
          page_or_node.find("turbo-frame##{@id}", wait: 0)
        rescue ::Capybara::ElementNotFound
          nil
        end

        def constraint_description
          parts = []
          parts << " loaded" if @loaded
          parts << " with content #{@content.inspect}" if @content
          parts.join
        end
      end
    end
  end
end
