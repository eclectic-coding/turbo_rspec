# frozen_string_literal: true

RSpec.describe TurboRspec::Matchers::HaveTurboFrame do
  include TurboRspec::Matchers

  def frame(id: "my-frame", content: nil)
    inner = content || ""
    "<turbo-frame id=\"#{id}\">#{inner}</turbo-frame>"
  end

  describe "#matches?" do
    it "matches any turbo frame" do
      expect(frame).to have_turbo_frame
    end

    it "does not match when no turbo-frame is present" do
      expect("<div>hello</div>").not_to have_turbo_frame
    end

    it "matches on id" do
      expect(frame(id: "messages")).to have_turbo_frame.with_id("messages")
    end

    it "does not match wrong id" do
      expect(frame(id: "messages")).not_to have_turbo_frame.with_id("notifications")
    end

    it "matches on content" do
      expect(frame(content: "Hello world")).to have_turbo_frame.with_content("Hello world")
    end

    it "does not match missing content" do
      expect(frame(content: "Hello")).not_to have_turbo_frame.with_content("Goodbye")
    end

    it "matches on rendering" do
      body = '<turbo-frame id="post"><!-- _post.html.erb --></turbo-frame>'
      expect(body).to have_turbo_frame.rendering("_post.html.erb")
    end

    it "chains id and content" do
      expect(frame(id: "messages", content: "Hello")).to have_turbo_frame
        .with_id("messages")
        .with_content("Hello")
    end

    it "matches one of multiple frames" do
      body = frame(id: "header") + frame(id: "footer", content: "Footer text")
      expect(body).to have_turbo_frame.with_id("footer").with_content("Footer text")
    end

    it "accepts a response object with a body method" do
      response = double(body: frame(id: "messages"))
      expect(response).to have_turbo_frame.with_id("messages")
    end
  end

  describe "failure messages" do
    subject(:matcher) { have_turbo_frame.with_id("messages") }

    it "describes what was expected" do
      matcher.matches?("<div></div>")
      expect(matcher.failure_message).to include("turbo frame")
      expect(matcher.failure_message).to include("messages")
      expect(matcher.failure_message).to include("no turbo frames were found")
    end

    it "lists found frames when id mismatches" do
      matcher.matches?(frame(id: "other"))
      expect(matcher.failure_message).to include("found 1 turbo frame(s)")
      expect(matcher.failure_message).to include('id="other"')
    end

    it "shows closest match with constraint diff" do
      m = have_turbo_frame.with_id("messages").with_content("Hello")
      m.matches?(frame(id: "messages", content: "Goodbye"))
      expect(m.failure_message).to include("closest match")
      expect(m.failure_message).to include("1/2")
      expect(m.failure_message).to include("✓ id")
      expect(m.failure_message).to include("✗ content")
    end

    it "shows rendering in constraint diff" do
      m = have_turbo_frame.rendering("_missing.html.erb")
      m.matches?(frame(id: "other"))
      expect(m.failure_message).to include("✗ rendering")
    end

    it "provides negated failure message" do
      expect(matcher.failure_message_when_negated).to include("not to contain")
    end

    it "includes with_content in failure message" do
      m = have_turbo_frame.with_content("Hello")
      m.matches?("<div></div>")
      expect(m.failure_message).to include('with content "Hello"')
    end

    it "includes rendering in failure message" do
      m = have_turbo_frame.rendering("_post.html.erb")
      m.matches?("<div></div>")
      expect(m.failure_message).to include('rendering "_post.html.erb"')
    end
  end

  describe "#description" do
    it "describes the matcher" do
      expect(have_turbo_frame.with_id("messages").description)
        .to eq('have turbo frame with id "messages"')
    end
  end
end
