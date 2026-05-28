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

    it "matches on rendering" do
      body = '<turbo-stream action="append" target="list"><template><!-- _item.html.erb --></template></turbo-stream>'
      expect(body).to have_turbo_stream.rendering("_item.html.erb")
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

    it "accepts a response object with a body method" do
      response = double(body: stream(action: "append", target: "list"))
      expect(response).to have_turbo_stream.with_action(:append).targeting("list")
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

    it "lists found streams when constraints do not match" do
      matcher.matches?(stream(action: "append", target: "list"))
      expect(matcher.failure_message).to include("found 1 turbo stream(s)")
      expect(matcher.failure_message).to include('action="append"')
    end

    it "shows closest match with constraint diff" do
      m = have_turbo_stream.with_action(:remove).targeting("list")
      m.matches?(stream(action: "append", target: "list"))
      expect(m.failure_message).to include("closest match")
      expect(m.failure_message).to include("1/2")
      expect(m.failure_message).to include("✗ action")
      expect(m.failure_message).to include("✓ target")
    end

    it "shows content in constraint diff" do
      m = have_turbo_stream.with_content("Bye")
      m.matches?(stream(action: "append", target: "list", content: "Hello"))
      expect(m.failure_message).to include("✗ content")
      expect(m.failure_message).to include("Bye")
    end

    it "shows ✓ action when action matches but other constraint fails" do
      m = have_turbo_stream.with_action(:append).targeting("other")
      m.matches?(stream(action: "append", target: "list"))
      expect(m.failure_message).to include("✓ action")
      expect(m.failure_message).to include("✗ target")
    end

    it "shows ✓ content when content matches but other constraint fails" do
      m = have_turbo_stream.with_action(:remove).with_content("Hello")
      m.matches?(stream(action: "append", target: "list", content: "Hello"))
      expect(m.failure_message).to include("✓ content")
    end

    it "shows targeting_all in constraint diff — mismatch" do
      body = '<turbo-stream action="remove" targets=".other"><template></template></turbo-stream>'
      m = have_turbo_stream.targeting_all(".items")
      m.matches?(body)
      expect(m.failure_message).to include("✗ targets")
    end

    it "shows ✓ targeting_all when it matches but other constraint fails" do
      body = '<turbo-stream action="remove" targets=".items"><template></template></turbo-stream>'
      m = have_turbo_stream.with_action(:append).targeting_all(".items")
      m.matches?(body)
      expect(m.failure_message).to include("✓ targets")
    end

    it "shows rendering in constraint diff — mismatch" do
      m = have_turbo_stream.rendering("_missing.html.erb")
      m.matches?(stream(action: "append", target: "list"))
      expect(m.failure_message).to include("✗ rendering")
    end

    it "shows ✓ rendering when it matches but other constraint fails" do
      body = '<turbo-stream action="remove" target="list"><template><!-- _item.html.erb --></template></turbo-stream>'
      m = have_turbo_stream.with_action(:append).rendering("_item.html.erb")
      m.matches?(body)
      expect(m.failure_message).to include("✓ rendering")
    end

    it "includes targeting_all in constraint description" do
      m = have_turbo_stream.targeting_all(".items")
      m.matches?("<div></div>")
      expect(m.failure_message).to include('targeting all ".items"')
    end

    it "includes with_content in constraint description" do
      m = have_turbo_stream.with_content("Hello")
      m.matches?("<div></div>")
      expect(m.failure_message).to include('with content "Hello"')
    end

    it "includes rendering in constraint description" do
      m = have_turbo_stream.rendering("_item.html.erb")
      m.matches?("<div></div>")
      expect(m.failure_message).to include('rendering "_item.html.erb"')
    end
  end

  describe "#description" do
    it "describes the matcher" do
      expect(have_turbo_stream.with_action(:append).targeting("list").description)
        .to eq('have turbo stream with action "append" targeting "list"')
    end
  end

  describe "assert_no_turbo_stream alias" do
    it "is available as an alias" do
      expect("<div></div>").not_to assert_no_turbo_stream
    end
  end

  describe "aggregate_failures" do
    it "works inside aggregate_failures blocks" do
      body = stream(action: "append", target: "list") + stream(action: "replace", target: "header")
      aggregate_failures do
        expect(body).to have_turbo_stream.with_action(:append).targeting("list")
        expect(body).to have_turbo_stream.with_action(:replace).targeting("header")
      end
    end
  end
end
