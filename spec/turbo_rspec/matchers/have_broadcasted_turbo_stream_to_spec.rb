# frozen_string_literal: true

RSpec.describe TurboRspec::Matchers::HaveBroadcastedTurboStreamTo do
  include TurboRspec::Matchers

  let(:stream) { "notifications" }

  def broadcast(stream_name, html)
    ActionCable.server.broadcast(stream_name, html)
  end

  def turbo_stream_html(action: "append", target: "list", content: nil)
    inner = content ? "<template>#{content}</template>" : "<template></template>"
    "<turbo-stream action=\"#{action}\" target=\"#{target}\">#{inner}</turbo-stream>"
  end

  before { ActionCable.server.pubsub.clear }

  describe "#matches?" do
    it "matches any broadcast to the stream" do
      expect { broadcast(stream, turbo_stream_html) }
        .to have_broadcasted_turbo_stream_to(stream)
    end

    it "does not match when nothing is broadcast" do
      expect { nil }
        .not_to have_broadcasted_turbo_stream_to(stream)
    end

    it "does not match broadcasts to a different stream" do
      expect { broadcast("other", turbo_stream_html) }
        .not_to have_broadcasted_turbo_stream_to(stream)
    end

    it "matches on action" do
      expect { broadcast(stream, turbo_stream_html(action: "replace")) }
        .to have_broadcasted_turbo_stream_to(stream).with_action(:replace)
    end

    it "does not match wrong action" do
      expect { broadcast(stream, turbo_stream_html(action: "append")) }
        .not_to have_broadcasted_turbo_stream_to(stream).with_action(:replace)
    end

    it "matches on target" do
      expect { broadcast(stream, turbo_stream_html(target: "messages")) }
        .to have_broadcasted_turbo_stream_to(stream).targeting("messages")
    end

    it "matches on content" do
      expect { broadcast(stream, turbo_stream_html(content: "Hello")) }
        .to have_broadcasted_turbo_stream_to(stream).with_content("Hello")
    end

    it "matches on targeting_all" do
      html = '<turbo-stream action="remove" targets=".item"><template></template></turbo-stream>'
      expect { broadcast(stream, html) }
        .to have_broadcasted_turbo_stream_to(stream).targeting_all(".item")
    end

    it "matches on rendering" do
      html = '<turbo-stream action="append" target="list"><template><!-- _item.html.erb --></template></turbo-stream>'
      expect { broadcast(stream, html) }
        .to have_broadcasted_turbo_stream_to(stream).rendering("_item.html.erb")
    end

    it "chains multiple constraints" do
      expect { broadcast(stream, turbo_stream_html(action: "append", target: "list")) }
        .to have_broadcasted_turbo_stream_to(stream).with_action(:append).targeting("list")
    end

    it "matches one of multiple broadcasts" do
      expect {
        broadcast(stream, turbo_stream_html(action: "append", target: "list"))
        broadcast(stream, turbo_stream_html(action: "replace", target: "header"))
      }.to have_broadcasted_turbo_stream_to(stream).with_action(:replace)
    end
  end

  describe "count qualifiers" do
    it "matches with .once" do
      expect { broadcast(stream, turbo_stream_html) }
        .to have_broadcasted_turbo_stream_to(stream).once
    end

    it "fails .once when broadcast twice" do
      expect {
        broadcast(stream, turbo_stream_html)
        broadcast(stream, turbo_stream_html)
      }.not_to have_broadcasted_turbo_stream_to(stream).once
    end

    it "matches with .twice" do
      expect {
        broadcast(stream, turbo_stream_html)
        broadcast(stream, turbo_stream_html)
      }.to have_broadcasted_turbo_stream_to(stream).twice
    end

    it "matches with .exactly(n).times" do
      expect {
        3.times { broadcast(stream, turbo_stream_html) }
      }.to have_broadcasted_turbo_stream_to(stream).exactly(3).times
    end

    it "matches with .at_least(n).times" do
      expect {
        3.times { broadcast(stream, turbo_stream_html) }
      }.to have_broadcasted_turbo_stream_to(stream).at_least(2).times
    end

    it "matches with .at_most(n).times" do
      expect { broadcast(stream, turbo_stream_html) }
        .to have_broadcasted_turbo_stream_to(stream).at_most(3).times
    end

    it "does not match when at_most exceeded" do
      expect {
        5.times { broadcast(stream, turbo_stream_html) }
      }.not_to have_broadcasted_turbo_stream_to(stream).at_most(3).times
    end
  end

  describe "with_attributes" do
    it "matches when all specified attributes are present" do
      html = '<turbo-stream action="append" target="list" data-foo="bar"><template></template></turbo-stream>'
      expect { broadcast(stream, html) }
        .to have_broadcasted_turbo_stream_to(stream).with_attributes("data-foo" => "bar")
    end

    it "does not match when an attribute value differs" do
      html = '<turbo-stream action="append" target="list" data-foo="bar"><template></template></turbo-stream>'
      expect { broadcast(stream, html) }
        .not_to have_broadcasted_turbo_stream_to(stream).with_attributes("data-foo" => "other")
    end

    it "chains with other constraints" do
      html = '<turbo-stream action="append" target="list" data-foo="bar"><template></template></turbo-stream>'
      expect { broadcast(stream, html) }
        .to have_broadcasted_turbo_stream_to(stream).with_action(:append).with_attributes("data-foo" => "bar")
    end

    it "includes attributes in constraint description" do
      expect(have_broadcasted_turbo_stream_to(stream).with_attributes("data-foo" => "bar").description)
        .to include("data-foo")
    end
  end

  describe "children_only" do
    let(:morph_html) { '<turbo-stream action="morph" target="body" children-only><template><p>Hi</p></template></turbo-stream>' }
    let(:plain_morph) { '<turbo-stream action="morph" target="body"><template><p>Hi</p></template></turbo-stream>' }

    it "matches a morph broadcast with children-only attribute" do
      expect { broadcast(stream, morph_html) }
        .to have_broadcasted_turbo_stream_to(stream).with_action(:morph).children_only
    end

    it "does not match when children-only attribute is absent" do
      expect { broadcast(stream, plain_morph) }
        .not_to have_broadcasted_turbo_stream_to(stream).with_action(:morph).children_only
    end

    it "includes children only in constraint description" do
      expect(have_broadcasted_turbo_stream_to(stream).children_only.description).to include("children only")
    end
  end

  describe "with_action validation" do
    after { TurboRspec.reset_configuration! }

    it "raises ArgumentError for unknown actions" do
      expect { have_broadcasted_turbo_stream_to(stream).with_action(:foobar) }
        .to raise_error(ArgumentError, /Unknown Turbo stream action "foobar"/)
    end

    it "includes registration hint in the error" do
      expect { have_broadcasted_turbo_stream_to(stream).with_action(:foobar) }
        .to raise_error(ArgumentError, /register_action/)
    end

    it "accepts all built-in actions without error" do
      TurboRspec::BUILTIN_ACTIONS.each do |action|
        expect { have_broadcasted_turbo_stream_to(stream).with_action(action) }.not_to raise_error
      end
    end

    it "accepts registered custom actions" do
      TurboRspec.register_action(:sparkle)
      expect { have_broadcasted_turbo_stream_to(stream).with_action(:sparkle) }.not_to raise_error
    end
  end

  describe "broadcast_turbo_stream_to alias" do
    it "is available" do
      expect { broadcast(stream, turbo_stream_html) }
        .to broadcast_turbo_stream_to(stream)
    end
  end

  describe "failure messages" do
    subject(:matcher) { have_broadcasted_turbo_stream_to(stream).with_action(:replace) }

    it "describes what was expected when nothing broadcast" do
      matcher.matches?(-> {})
      expect(matcher.failure_message).to include(stream)
      expect(matcher.failure_message).to include("replace")
      expect(matcher.failure_message).to include("no broadcasts were made")
    end

    it "lists found streams when broadcasts exist but none match" do
      matcher.matches?(-> { broadcast(stream, turbo_stream_html(action: "append", target: "list")) })
      expect(matcher.failure_message).to include("1 stream(s) broadcast")
      expect(matcher.failure_message).to include('action="append"')
    end

    it "shows closest match with constraint diff when broadcasts exist" do
      matcher.matches?(-> { broadcast(stream, turbo_stream_html(action: "append", target: "list")) })
      expect(matcher.failure_message).to include("closest match")
      expect(matcher.failure_message).to include("✗ action")
    end

    it "shows no closest match section when no constraints set" do
      m = have_broadcasted_turbo_stream_to(stream)
      m.matches?(-> {})
      expect(m.failure_message).not_to include("closest match")
    end

    it "provides negated failure message" do
      expect(matcher.failure_message_when_negated).to include("not to broadcast")
    end
  end

  describe "stream name resolution" do
    it "uses to_s on a non-string object when Turbo is not defined" do
      obj = double(to_s: "custom_stream")
      expect { broadcast("custom_stream", turbo_stream_html) }
        .to have_broadcasted_turbo_stream_to(obj)
    end

    it "calls Turbo::StreamsChannel.broadcasting_for when Turbo is defined" do
      stub_const("Turbo::StreamsChannel", double(broadcasting_for: "turbo_stream"))
      expect { broadcast("turbo_stream", turbo_stream_html) }
        .to have_broadcasted_turbo_stream_to(double)
    end
  end

  describe "non-JSON broadcast payload" do
    it "does not match and does not raise" do
      allow(ActionCable.server.pubsub).to receive(:broadcasts)
        .and_return([], ["not-json{"])
      expect { nil }.not_to have_broadcasted_turbo_stream_to(stream)
    end
  end

  describe "failure messages" do
    describe "constraint_diff branches" do
      def broadcast_html(action: "append", target: "list", content: nil, targets: nil, **extra)
        attrs = extra.map { |k, v| " #{k}=\"#{v}\"" }.join
        inner = content ? "<template>#{content}</template>" : "<template></template>"
        if targets
          "<turbo-stream action=\"#{action}\" targets=\"#{targets}\"#{attrs}>#{inner}</turbo-stream>"
        else
          "<turbo-stream action=\"#{action}\" target=\"#{target}\"#{attrs}>#{inner}</turbo-stream>"
        end
      end

      it "shows ✓ action and ✗ target when action matches but target fails" do
        m = have_broadcasted_turbo_stream_to(stream).with_action(:append).targeting("other")
        m.matches?(-> { broadcast(stream, broadcast_html(action: "append", target: "list")) })
        expect(m.failure_message).to include("✓ action").and include("✗ target")
      end

      it "shows ✓ target and ✗ action when target matches but action fails" do
        m = have_broadcasted_turbo_stream_to(stream).with_action(:replace).targeting("list")
        m.matches?(-> { broadcast(stream, broadcast_html(action: "append", target: "list")) })
        expect(m.failure_message).to include("✗ action").and include("✓ target")
      end

      it "shows ✓ targets when targeting_all matches but action fails" do
        html = broadcast_html(action: "append", targets: ".items")
        m = have_broadcasted_turbo_stream_to(stream).with_action(:replace).targeting_all(".items")
        m.matches?(-> { broadcast(stream, html) })
        expect(m.failure_message).to include("✗ action").and include("✓ targets")
      end

      it "shows ✗ targets when targeting_all does not match" do
        html = broadcast_html(action: "append", targets: ".other")
        m = have_broadcasted_turbo_stream_to(stream).with_action(:append).targeting_all(".items")
        m.matches?(-> { broadcast(stream, html) })
        expect(m.failure_message).to include("✓ action").and include("✗ targets")
      end

      it "shows ✓ content when content matches but action fails" do
        m = have_broadcasted_turbo_stream_to(stream).with_action(:replace).with_content("Hello")
        m.matches?(-> { broadcast(stream, broadcast_html(action: "append", content: "Hello")) })
        expect(m.failure_message).to include("✓ content")
      end

      it "shows ✗ content when content does not match" do
        m = have_broadcasted_turbo_stream_to(stream).with_action(:append).with_content("Bye")
        m.matches?(-> { broadcast(stream, broadcast_html(action: "append", content: "Hello")) })
        expect(m.failure_message).to include("✓ action").and include("✗ content")
      end

      it "shows ✓ rendering when partial matches but action fails" do
        html = '<turbo-stream action="append" target="list"><template><!-- _item.html.erb --></template></turbo-stream>'
        m = have_broadcasted_turbo_stream_to(stream).with_action(:replace).rendering("_item.html.erb")
        m.matches?(-> { broadcast(stream, html) })
        expect(m.failure_message).to include("✓ rendering")
      end

      it "shows ✗ rendering when partial does not match" do
        html = '<turbo-stream action="append" target="list"><template><!-- _other.html.erb --></template></turbo-stream>'
        m = have_broadcasted_turbo_stream_to(stream).with_action(:append).rendering("_item.html.erb")
        m.matches?(-> { broadcast(stream, html) })
        expect(m.failure_message).to include("✓ action").and include("✗ rendering")
      end

      it "shows ✓ attr when attribute matches but action fails" do
        html = broadcast_html(action: "append", "data-foo": "bar")
        m = have_broadcasted_turbo_stream_to(stream).with_action(:replace).with_attributes("data-foo" => "bar")
        m.matches?(-> { broadcast(stream, html) })
        expect(m.failure_message).to include("✓ attr[data-foo]")
      end

      it "shows ✓ children-only when attribute present but action fails" do
        html = '<turbo-stream action="morph" target="body" children-only><template></template></turbo-stream>'
        m = have_broadcasted_turbo_stream_to(stream).with_action(:replace).children_only
        m.matches?(-> { broadcast(stream, html) })
        expect(m.failure_message).to include("✓ children-only")
      end
    end

    describe "constraint_description branches" do
      it "includes targeting in failure message" do
        m = have_broadcasted_turbo_stream_to(stream).targeting("list")
        m.matches?(-> {})
        expect(m.failure_message).to include('targeting "list"')
      end

      it "includes targeting_all in failure message" do
        m = have_broadcasted_turbo_stream_to(stream).targeting_all(".items")
        m.matches?(-> {})
        expect(m.failure_message).to include('targeting all ".items"')
      end

      it "includes with_content in failure message" do
        m = have_broadcasted_turbo_stream_to(stream).with_content("Hello")
        m.matches?(-> {})
        expect(m.failure_message).to include('with content "Hello"')
      end

      it "includes rendering in failure message" do
        m = have_broadcasted_turbo_stream_to(stream).rendering("_item.html.erb")
        m.matches?(-> {})
        expect(m.failure_message).to include('rendering "_item.html.erb"')
      end
    end

    describe "count_description branches" do
      it "includes exactly count in failure message" do
        m = have_broadcasted_turbo_stream_to(stream).exactly(2).times
        m.matches?(-> {})
        expect(m.failure_message).to include("exactly 2 time(s)")
      end

      it "includes at_least count in failure message" do
        m = have_broadcasted_turbo_stream_to(stream).at_least(3).times
        m.matches?(-> {})
        expect(m.failure_message).to include("at least 3 time(s)")
      end

      it "includes at_most count in failure message" do
        m = have_broadcasted_turbo_stream_to(stream).at_most(2).times
        m.matches?(-> { 5.times { broadcast(stream, turbo_stream_html) } })
        expect(m.failure_message).to include("at most 2 time(s)")
      end
    end

    describe "found_message branch" do
      it "reports count when broadcasts exist but count qualifier not met" do
        m = have_broadcasted_turbo_stream_to(stream).exactly(3).times
        m.matches?(-> { broadcast(stream, turbo_stream_html) })
        expect(m.failure_message).to include("found 1 matching broadcast(s)")
      end

      it "shows no-broadcasts message when stream is empty" do
        m = have_broadcasted_turbo_stream_to(stream).with_action(:append)
        m.matches?(-> {})
        expect(m.failure_message).to include("no broadcasts were made")
      end

      it "shows stream list when broadcasts exist but none match" do
        m = have_broadcasted_turbo_stream_to(stream).with_action(:replace)
        m.matches?(-> { broadcast(stream, turbo_stream_html(action: "append")) })
        expect(m.failure_message).to include("1 stream(s) broadcast")
        expect(m.failure_message).to include("closest match")
      end

      it "shows ✗ attr in constraint diff when attribute does not match" do
        html = '<turbo-stream action="append" target="list"><template></template></turbo-stream>'
        m = have_broadcasted_turbo_stream_to(stream).with_attributes("data-foo" => "bar")
        m.matches?(-> { broadcast(stream, html) })
        expect(m.failure_message).to include("✗ attr[data-foo]")
      end

      it "shows ✗ children-only in constraint diff when attribute is absent" do
        m = have_broadcasted_turbo_stream_to(stream).with_action(:morph).children_only
        m.matches?(-> { broadcast(stream, turbo_stream_html(action: "morph")) })
        expect(m.failure_message).to include("✗ children-only")
      end

      it "shows stream list without closest match when no constraints" do
        m = have_broadcasted_turbo_stream_to(stream)
        m.matches?(-> { broadcast("other", turbo_stream_html) })
        expect(m.failure_message).to include("no broadcasts were made")
      end

      it "skips non-JSON payloads in stream list" do
        allow(ActionCable.server.pubsub).to receive(:broadcasts)
          .and_return([], ["not-json{"])
        m = have_broadcasted_turbo_stream_to(stream).with_action(:append)
        m.matches?(-> {})
        expect(m.failure_message).to include("no broadcasts were made")
      end
    end
  end

  describe "#description" do
    it "describes the matcher" do
      expect(have_broadcasted_turbo_stream_to(stream).with_action(:append).targeting("list").description)
        .to include(stream).and include("append").and include("list")
    end
  end
end
