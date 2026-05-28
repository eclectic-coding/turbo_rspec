# frozen_string_literal: true

RSpec.describe TurboRspec::Matchers::HaveTurboStream do
  include TurboRspec::Matchers

  def stream(action: "append", target: "list", content: nil)
    inner = content ? "<template>#{content}</template>" : "<template></template>"
    "<turbo-stream action=\"#{action}\" target=\"#{target}\">#{inner}</turbo-stream>"
  end

  describe "#matches?" do
    it "matches any turbo stream" do
      expect(stream).to have_turbo_stream
    end

    it "does not match when no turbo-stream is present" do
      expect("<div>hello</div>").not_to have_turbo_stream
    end

    it "matches on action" do
      expect(stream(action: "replace")).to have_turbo_stream.with_action(:replace)
    end

    it "does not match wrong action" do
      expect(stream(action: "append")).not_to have_turbo_stream.with_action(:replace)
    end

    it "matches on target" do
      expect(stream(target: "messages")).to have_turbo_stream.targeting("messages")
    end

    it "does not match wrong target" do
      expect(stream(target: "messages")).not_to have_turbo_stream.targeting("notifications")
    end

    it "matches on content" do
      expect(stream(content: "Hello world")).to have_turbo_stream.with_content("Hello world")
    end

    it "does not match missing content" do
      expect(stream(content: "Hello")).not_to have_turbo_stream.with_content("Goodbye")
    end

    it "matches on targeting_all" do
      body = '<turbo-stream action="remove" targets=".item"><template></template></turbo-stream>'
      expect(body).to have_turbo_stream.targeting_all(".item")
    end

    it "chains multiple constraints" do
      expect(stream(action: "append", target: "list")).to have_turbo_stream
        .with_action(:append)
        .targeting("list")
    end

    it "matches one of multiple streams" do
      body = stream(action: "append", target: "list") + stream(action: "replace", target: "header")
      expect(body).to have_turbo_stream.with_action(:replace).targeting("header")
    end
  end

  describe "failure messages" do
    subject(:matcher) { have_turbo_stream.with_action(:replace).targeting("messages") }

    it "describes what was expected" do
      matcher.matches?("<div></div>")
      expect(matcher.failure_message).to include("turbo stream")
      expect(matcher.failure_message).to include("replace")
      expect(matcher.failure_message).to include("messages")
    end

    it "provides negated failure message" do
      expect(matcher.failure_message_when_negated).to include("not to contain")
    end
  end

  describe "#description" do
    it "describes the matcher" do
      expect(have_turbo_stream.with_action(:append).targeting("list").description)
        .to eq('have turbo stream with action "append" targeting "list"')
    end
  end
end
