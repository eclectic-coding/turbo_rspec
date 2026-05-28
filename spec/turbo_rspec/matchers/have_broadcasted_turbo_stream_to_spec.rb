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

  describe "#description" do
    it "describes the matcher" do
      expect(have_broadcasted_turbo_stream_to(stream).with_action(:append).targeting("list").description)
        .to include(stream).and include("append").and include("list")
    end
  end
end
