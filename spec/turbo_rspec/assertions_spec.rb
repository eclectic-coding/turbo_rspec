# frozen_string_literal: true

RSpec.describe TurboRspec::Assertions do
  subject(:test_case) { Object.new.extend(described_class) }

  # Minimal assert implementation to avoid depending on minitest in specs
  before do
    test_case.define_singleton_method(:assert) do |condition, message = nil|
      raise message || "assertion failed" unless condition
    end
  end

  def stream(action: "append", target: "list", content: nil)
    inner = content ? "<template>#{content}</template>" : "<template></template>"
    "<turbo-stream action=\"#{action}\" target=\"#{target}\">#{inner}</turbo-stream>"
  end

  def frame(id: "my-frame", content: nil)
    "<turbo-frame id=\"#{id}\">#{content}</turbo-frame>"
  end

  describe "#assert_turbo_stream" do
    it "passes when a matching stream is present" do
      expect { test_case.assert_turbo_stream(stream, action: :append) }.not_to raise_error
    end

    it "raises when no stream matches" do
      expect { test_case.assert_turbo_stream(stream, action: :replace) }.to raise_error(/replace/)
    end

    it "supports target constraint" do
      expect { test_case.assert_turbo_stream(stream, target: "list") }.not_to raise_error
    end

    it "supports targets (CSS selector) constraint" do
      body = '<turbo-stream action="remove" targets=".item"><template></template></turbo-stream>'
      expect { test_case.assert_turbo_stream(body, targets: ".item") }.not_to raise_error
    end

    it "supports content constraint" do
      expect { test_case.assert_turbo_stream(stream(content: "Hello"), content: "Hello") }.not_to raise_error
    end

    it "supports partial constraint" do
      body = '<turbo-stream action="append" target="list"><template><!-- _item.html.erb --></template></turbo-stream>'
      expect { test_case.assert_turbo_stream(body, partial: "_item.html.erb") }.not_to raise_error
    end

    it "uses custom message when provided" do
      expect { test_case.assert_turbo_stream(stream, action: :replace, message: "oops") }.to raise_error("oops")
    end
  end

  describe "#refute_turbo_stream" do
    it "passes when no matching stream is present" do
      expect { test_case.refute_turbo_stream(stream, action: :replace) }.not_to raise_error
    end

    it "raises when a matching stream is found" do
      expect { test_case.refute_turbo_stream(stream, action: :append) }.to raise_error(/not/)
    end

    it "uses custom message when provided" do
      expect { test_case.refute_turbo_stream(stream, action: :append, message: "oops") }.to raise_error("oops")
    end
  end

  describe "#assert_turbo_frame" do
    it "passes when a matching frame is present" do
      expect { test_case.assert_turbo_frame(frame) }.not_to raise_error
    end

    it "raises when no frame matches" do
      expect { test_case.assert_turbo_frame("<div></div>") }.to raise_error(/turbo frame/)
    end

    it "supports id constraint" do
      expect { test_case.assert_turbo_frame(frame(id: "messages"), id: "messages") }.not_to raise_error
    end

    it "supports content constraint" do
      expect { test_case.assert_turbo_frame(frame(content: "Hello"), content: "Hello") }.not_to raise_error
    end

    it "supports partial constraint" do
      body = '<turbo-frame id="post"><!-- _post.html.erb --></turbo-frame>'
      expect { test_case.assert_turbo_frame(body, partial: "_post.html.erb") }.not_to raise_error
    end

    it "uses custom message when provided" do
      expect { test_case.assert_turbo_frame("<div></div>", message: "oops") }.to raise_error("oops")
    end
  end

  describe "#refute_turbo_frame" do
    it "passes when no matching frame is present" do
      expect { test_case.refute_turbo_frame("<div></div>") }.not_to raise_error
    end

    it "raises when a matching frame is found" do
      expect { test_case.refute_turbo_frame(frame) }.to raise_error(/not/)
    end

    it "uses custom message when provided" do
      expect { test_case.refute_turbo_frame(frame, message: "oops") }.to raise_error("oops")
    end
  end
end
