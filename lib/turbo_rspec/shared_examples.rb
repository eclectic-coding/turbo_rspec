# frozen_string_literal: true

# :nocov:
if defined?(RSpec)
  # :nocov:
  RSpec.shared_examples "a turbo stream response" do |action: nil, target: nil, targets: nil, content: nil, partial: nil|
    it "responds with a turbo stream" do
      matcher = have_turbo_stream
      matcher.with_action(action) if action
      matcher.targeting(target) if target
      matcher.targeting_all(targets) if targets
      matcher.with_content(content) if content
      matcher.rendering(partial) if partial
      expect(response).to matcher
    end
  end

  RSpec.shared_examples "a turbo frame response" do |id: nil, content: nil, partial: nil|
    it "responds with a turbo frame" do
      matcher = have_turbo_frame
      matcher.with_id(id) if id
      matcher.with_content(content) if content
      matcher.rendering(partial) if partial
      expect(response).to matcher
    end
  end
end
