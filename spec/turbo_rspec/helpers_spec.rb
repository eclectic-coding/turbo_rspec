# frozen_string_literal: true

RSpec.describe TurboRspec::Helpers do
  include described_class
  include TurboRspec::Matchers

  describe "#turbo_stream_html" do
    it "builds a basic turbo stream element" do
      html = turbo_stream_html(action: :append, target: "list")
      expect(html).to have_turbo_stream.with_action(:append).targeting("list")
    end

    it "includes content in the template" do
      html = turbo_stream_html(action: :append, target: "list", content: "Hello")
      expect(html).to have_turbo_stream.with_content("Hello")
    end

    it "supports targets (CSS selector)" do
      html = turbo_stream_html(action: :remove, targets: ".item")
      expect(html).to have_turbo_stream.targeting_all(".item")
    end

    it "renders an empty template when no content given" do
      html = turbo_stream_html(action: :remove, target: "list")
      expect(html).to include("<template></template>")
    end
  end

  describe "#turbo_frame_html" do
    it "builds a turbo frame element" do
      html = turbo_frame_html(id: "messages")
      expect(html).to have_turbo_frame.with_id("messages")
    end

    it "includes content" do
      html = turbo_frame_html(id: "messages", content: "Hello")
      expect(html).to have_turbo_frame.with_content("Hello")
    end
  end
end
