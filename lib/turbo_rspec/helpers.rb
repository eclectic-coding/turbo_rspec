# frozen_string_literal: true

module TurboRspec
  module Helpers
    def turbo_stream_html(action:, target: nil, targets: nil, content: nil)
      attrs = "action=\"#{action}\""
      attrs += " target=\"#{target}\"" if target
      attrs += " targets=\"#{targets}\"" if targets
      inner = content ? "<template>#{content}</template>" : "<template></template>"
      "<turbo-stream #{attrs}>#{inner}</turbo-stream>"
    end

    def turbo_frame_html(id:, content: nil)
      "<turbo-frame id=\"#{id}\">#{content}</turbo-frame>"
    end
  end
end
