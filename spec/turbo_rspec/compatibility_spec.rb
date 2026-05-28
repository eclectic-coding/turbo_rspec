# frozen_string_literal: true

RSpec.describe "compatibility" do
  include TurboRspec::Matchers

  describe "refresh action (Turbo 8)" do
    let(:body) { '<turbo-stream action="refresh"></turbo-stream>' }

    it "matches a refresh stream with no target" do
      expect(body).to have_turbo_stream.with_action(:refresh)
    end

    it "does not require a target" do
      expect(body).to have_turbo_stream
    end
  end

  describe "morph action (Turbo Morphing)" do
    let(:body) { '<turbo-stream action="morph" target="body"><template><p>Updated</p></template></turbo-stream>' }

    it "matches a morph stream" do
      expect(body).to have_turbo_stream.with_action(:morph).targeting("body")
    end

    it "matches morph content" do
      expect(body).to have_turbo_stream.with_action(:morph).with_content("Updated")
    end
  end

  describe "multi-stream response body" do
    let(:body) do
      '<turbo-stream action="append" target="messages"><template>Hello</template></turbo-stream>' \
        '<turbo-stream action="replace" target="header"><template></template></turbo-stream>' \
        '<turbo-stream action="remove" target="notice"><template></template></turbo-stream>'
    end

    it "matches any stream in a multi-stream response" do
      expect(body).to have_turbo_stream.with_action(:replace)
    end

    it "matches all streams with have_turbo_streams" do
      expect(body).to have_turbo_streams(
        have_turbo_stream.with_action(:append).targeting("messages"),
        have_turbo_stream.with_action(:replace).targeting("header"),
        have_turbo_stream.with_action(:remove).targeting("notice")
      )
    end

    it "does not match a stream that is not present" do
      expect(body).not_to have_turbo_stream.with_action(:update)
    end
  end

  describe "graceful no-op when turbo-rails is absent" do
    it "does not raise when turbo-rails is not loaded" do
      expect { TurboRspec::Matchers::HaveTurboStream.new }.not_to raise_error
    end

    it "does not raise when requiring turbo_rspec without turbo-rails" do
      expect { require "turbo_rspec" }.not_to raise_error
    end
  end
end
