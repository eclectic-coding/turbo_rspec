# frozen_string_literal: true

RSpec.describe TurboRspec::Matchers::HaveTurboStream do
  include TurboRspec::Matchers

  def stream(action: "append", target: "list", content: nil, **attrs)
    attr_str = attrs.map { |k, v| " #{k}=\"#{v}\"" }.join
    inner = content ? "<template>#{content}</template>" : "<template></template>"
    "<turbo-stream action=\"#{action}\" target=\"#{target}\"#{attr_str}>#{inner}</turbo-stream>"
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

  describe "with_attributes" do
    it "matches when all specified attributes are present" do
      expect(stream("data-foo": "bar")).to have_turbo_stream.with_attributes("data-foo" => "bar")
    end

    it "does not match when an attribute value differs" do
      expect(stream("data-foo": "bar")).not_to have_turbo_stream.with_attributes("data-foo" => "other")
    end

    it "does not match when an attribute is absent" do
      expect(stream).not_to have_turbo_stream.with_attributes("data-foo" => "bar")
    end

    it "matches multiple attributes" do
      expect(stream("data-a": "1", "data-b": "2")).to have_turbo_stream.with_attributes("data-a" => "1", "data-b" => "2")
    end

    it "accepts symbol keys" do
      expect(stream("data-foo": "bar")).to have_turbo_stream.with_attributes("data-foo": "bar")
    end

    it "chains with other constraints" do
      expect(stream(action: "append", target: "list", "data-foo": "bar"))
        .to have_turbo_stream.with_action(:append).targeting("list").with_attributes("data-foo" => "bar")
    end

    it "includes attributes in failure message" do
      m = have_turbo_stream.with_attributes("data-foo" => "bar")
      m.matches?(stream)
      expect(m.failure_message).to include("data-foo")
    end

    it "shows ✗ attr in constraint diff" do
      m = have_turbo_stream.with_action(:append).with_attributes("data-foo" => "bar")
      m.matches?(stream)
      expect(m.failure_message).to include("✗ attr[data-foo]")
    end

    it "shows ✓ attr in constraint diff when attribute matches but other constraint fails" do
      m = have_turbo_stream.with_action(:remove).with_attributes("data-foo" => "bar")
      m.matches?(stream("data-foo": "bar"))
      expect(m.failure_message).to include("✓ attr[data-foo]")
    end
  end

  describe "children_only" do
    let(:morph_stream) { '<turbo-stream action="morph" target="body" children-only><template><p>Hi</p></template></turbo-stream>' }
    let(:plain_morph) { '<turbo-stream action="morph" target="body"><template><p>Hi</p></template></turbo-stream>' }

    it "matches a morph stream with children-only attribute" do
      expect(morph_stream).to have_turbo_stream.with_action(:morph).children_only
    end

    it "does not match when children-only attribute is absent" do
      expect(plain_morph).not_to have_turbo_stream.with_action(:morph).children_only
    end

    it "chains with other constraints" do
      expect(morph_stream).to have_turbo_stream.with_action(:morph).targeting("body").children_only
    end

    it "includes children only in constraint description" do
      expect(have_turbo_stream.children_only.description).to include("children only")
    end

    it "shows ✗ children-only in constraint diff when absent" do
      m = have_turbo_stream.with_action(:morph).children_only
      m.matches?(plain_morph)
      expect(m.failure_message).to include("✗ children-only")
    end

    it "shows ✓ children-only in constraint diff when present but other constraint fails" do
      m = have_turbo_stream.with_action(:replace).children_only
      m.matches?(morph_stream)
      expect(m.failure_message).to include("✓ children-only")
    end
  end

  describe "with_action validation" do
    after { TurboRspec.reset_configuration! }

    it "raises ArgumentError for unknown actions" do
      expect { have_turbo_stream.with_action(:foobar) }
        .to raise_error(ArgumentError, /Unknown Turbo stream action "foobar"/)
    end

    it "includes registration hint in the error" do
      expect { have_turbo_stream.with_action(:foobar) }
        .to raise_error(ArgumentError, /register_action/)
    end

    it "accepts built-in actions without error" do
      TurboRspec::BUILTIN_ACTIONS.each do |action|
        expect { have_turbo_stream.with_action(action) }.not_to raise_error
      end
    end

    it "accepts registered custom actions" do
      TurboRspec.register_action(:sparkle)
      expect { have_turbo_stream.with_action(:sparkle) }.not_to raise_error
    end
  end

  describe "count qualifiers" do
    def two_appends
      stream(action: "append", target: "list") + stream(action: "append", target: "list")
    end

    it "matches once" do
      expect(stream).to have_turbo_stream.once
    end

    it "does not match once when two streams are present" do
      expect(two_appends).not_to have_turbo_stream.with_action(:append).once
    end

    it "matches twice" do
      expect(two_appends).to have_turbo_stream.with_action(:append).twice
    end

    it "matches exactly(n)" do
      expect(two_appends).to have_turbo_stream.with_action(:append).exactly(2).times
    end

    it "does not match exactly(n) when count differs" do
      expect(stream).not_to have_turbo_stream.exactly(2).times
    end

    it "matches at_least(n)" do
      expect(two_appends).to have_turbo_stream.at_least(1).times
    end

    it "does not match at_least(n) when count is too low" do
      expect(stream).not_to have_turbo_stream.at_least(2).times
    end

    it "matches at_most(n)" do
      expect(stream).to have_turbo_stream.at_most(1).times
    end

    it "does not match at_most(n) when count exceeds limit" do
      expect(two_appends).not_to have_turbo_stream.at_most(1).times
    end

    it "includes count in failure message" do
      m = have_turbo_stream.with_action(:append).exactly(3).times
      m.matches?(two_appends)
      expect(m.failure_message).to include("exactly 3 time(s)")
      expect(m.failure_message).to include("2 of 2 stream(s) matched")
    end

    it "includes exactly count in description" do
      expect(have_turbo_stream.with_action(:append).exactly(2).times.description)
        .to include("exactly 2 time(s)")
    end

    it "includes at_least count in description" do
      expect(have_turbo_stream.at_least(2).times.description).to include("at least 2 time(s)")
    end

    it "includes at_most count in description" do
      expect(have_turbo_stream.at_most(3).times.description).to include("at most 3 time(s)")
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
