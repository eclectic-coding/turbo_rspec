# frozen_string_literal: true

module TurboRspec
  # Factory helpers for building Turbo HTML strings inline in tests.
  # Auto-included into +type: :request+ and +type: :controller+ example groups.
  module Helpers
    # Builds a +<turbo-stream>+ HTML string for use in test assertions.
    #
    # @param action [Symbol, String] the stream action (e.g. +:append+, +:replace+)
    # @param target [String, nil] the +target+ DOM id attribute
    # @param targets [String, nil] the +targets+ CSS selector attribute
    # @param content [String, nil] optional content to place inside the template
    # @return [String]
    #
    # @example
    #   turbo_stream_html(action: :append, target: "messages", content: "Hello")
    #   turbo_stream_html(action: :remove, targets: ".item")
    def turbo_stream_html(action:, target: nil, targets: nil, content: nil)
      attrs = "action=\"#{action}\""
      attrs += " target=\"#{target}\"" if target
      attrs += " targets=\"#{targets}\"" if targets
      inner = content ? "<template>#{content}</template>" : "<template></template>"
      "<turbo-stream #{attrs}>#{inner}</turbo-stream>"
    end

    # Builds a +<turbo-frame>+ HTML string for use in test assertions.
    #
    # @param id [String] the frame's +id+ attribute
    # @param content [String, nil] optional content inside the frame
    # @return [String]
    #
    # @example
    #   turbo_frame_html(id: "messages", content: "Hello")
    def turbo_frame_html(id:, content: nil)
      "<turbo-frame id=\"#{id}\">#{content}</turbo-frame>"
    end
  end
end
