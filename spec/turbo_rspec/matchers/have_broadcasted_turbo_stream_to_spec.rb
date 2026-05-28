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
      expect(matcher.failure_message).to include("no matching broadcasts")
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
    end
  end

  describe "#description" do
    it "describes the matcher" do
      expect(have_broadcasted_turbo_stream_to(stream).with_action(:append).targeting("list").description)
        .to include(stream).and include("append").and include("list")
    end
  end
end
