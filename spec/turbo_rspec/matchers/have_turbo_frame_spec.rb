# frozen_string_literal: true

RSpec.describe TurboRspec::Matchers::HaveTurboFrame do
  include TurboRspec::Matchers

  def frame(id: "my-frame", content: nil, **attrs)
    attr_str = attrs.map { |k, v| " #{k}=\"#{v}\"" }.join
    inner = content || ""
    "<turbo-frame id=\"#{id}\"#{attr_str}>#{inner}</turbo-frame>"
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

    it "shows rendering in constraint diff — mismatch" do
      m = have_turbo_frame.rendering("_missing.html.erb")
      m.matches?(frame(id: "other"))
      expect(m.failure_message).to include("✗ rendering")
    end

    it "shows ✓ content when content matches but id fails" do
      m = have_turbo_frame.with_id("other").with_content("Hello")
      m.matches?(frame(id: "messages", content: "Hello"))
      expect(m.failure_message).to include("✓ content")
    end

    it "shows ✓ rendering when it matches but id fails" do
      body = '<turbo-frame id="wrong"><!-- _post.html.erb --></turbo-frame>'
      m = have_turbo_frame.with_id("other").rendering("_post.html.erb")
      m.matches?(body)
      expect(m.failure_message).to include("✓ rendering")
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

  describe "with_attributes" do
    it "matches when all specified attributes are present" do
      expect(frame("data-foo": "bar")).to have_turbo_frame.with_attributes("data-foo" => "bar")
    end

    it "does not match when an attribute value differs" do
      expect(frame("data-foo": "bar")).not_to have_turbo_frame.with_attributes("data-foo" => "other")
    end

    it "does not match when an attribute is absent" do
      expect(frame).not_to have_turbo_frame.with_attributes("data-foo" => "bar")
    end

    it "chains with id and content" do
      expect(frame(id: "msg", content: "Hi", "data-x": "1"))
        .to have_turbo_frame.with_id("msg").with_content("Hi").with_attributes("data-x" => "1")
    end

    it "shows ✗ attr in constraint diff" do
      m = have_turbo_frame.with_id("my-frame").with_attributes("data-foo" => "bar")
      m.matches?(frame)
      expect(m.failure_message).to include("✗ attr[data-foo]")
    end

    it "shows ✓ attr in constraint diff when attribute matches but other constraint fails" do
      m = have_turbo_frame.with_id("other").with_attributes("data-foo" => "bar")
      m.matches?(frame("data-foo": "bar"))
      expect(m.failure_message).to include("✓ attr[data-foo]")
    end

    it "includes attributes in constraint description" do
      expect(have_turbo_frame.with_attributes("data-foo" => "bar").description)
        .to include("data-foo")
    end
  end

  describe "#description" do
    it "describes the matcher" do
      expect(have_turbo_frame.with_id("messages").description)
        .to eq('have turbo frame with id "messages"')
    end
  end
end
