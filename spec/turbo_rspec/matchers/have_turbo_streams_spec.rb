# frozen_string_literal: true

RSpec.describe TurboRspec::Matchers::HaveTurboStreams do
  include TurboRspec::Matchers

  def stream(action: "append", target: "list")
    "<turbo-stream action=\"#{action}\" target=\"#{target}\"><template></template></turbo-stream>"
  end

  let(:body) do
    stream(action: "append", target: "messages") +
      stream(action: "replace", target: "header") +
      stream(action: "remove", target: "sidebar")
  end

  describe "#matches?" do
    it "matches when all specified streams are present" do
      expect(body).to have_turbo_streams(
        have_turbo_stream.with_action(:append).targeting("messages"),
        have_turbo_stream.with_action(:replace).targeting("header")
      )
    end

    it "fails when any stream is missing" do
      expect(body).not_to have_turbo_streams(
        have_turbo_stream.with_action(:append).targeting("messages"),
        have_turbo_stream.with_action(:update).targeting("footer")
      )
    end

    it "matches a single stream" do
      expect(body).to have_turbo_streams(have_turbo_stream.with_action(:remove))
    end

    it "accepts a response object with a body method" do
      response = double(body: body)
      expect(response).to have_turbo_streams(have_turbo_stream.with_action(:append))
    end
  end

  describe "failure messages" do
    subject(:matcher) do
      have_turbo_streams(
        have_turbo_stream.with_action(:append).targeting("messages"),
        have_turbo_stream.with_action(:update).targeting("footer")
      )
    end

    it "lists unmatched streams" do
      matcher.matches?(body)
      expect(matcher.failure_message).to include("missing")
      expect(matcher.failure_message).to include("update")
      expect(matcher.failure_message).to include("footer")
      expect(matcher.failure_message).to include("found streams")
    end

    it "reports empty when no streams found" do
      matcher.matches?("<div></div>")
      expect(matcher.failure_message).to include("(none)")
    end

    it "provides negated failure message" do
      expect(matcher.failure_message_when_negated).to include("not to contain")
    end
  end

  describe "#description" do
    it "lists all expected streams" do
      matcher = have_turbo_streams(
        have_turbo_stream.with_action(:append),
        have_turbo_stream.with_action(:replace)
      )
      expect(matcher.description).to include("append").and include("replace")
    end
  end
end
