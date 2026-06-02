# frozen_string_literal: true

require "tmpdir"

RSpec.describe TurboRspec::Matchers::MatchTurboStreamSnapshot do
  include TurboRspec::Matchers

  let(:stream) { '<turbo-stream action="append" target="list"><template>Hello</template></turbo-stream>' }
  let(:other_stream) { '<turbo-stream action="replace" target="list"><template>Bye</template></turbo-stream>' }

  around do |example|
    Dir.mktmpdir do |dir|
      TurboRspec.configure { |c| c.snapshot_dir = dir }
      example.run
    end
  end

  after { TurboRspec.reset_configuration! }

  describe "#matches?" do
    it "creates a snapshot and passes on the first run" do
      expect(stream).to match_turbo_stream_snapshot("messages/new")
    end

    it "matches on the second run when content is identical" do
      expect(stream).to match_turbo_stream_snapshot("messages/new")
      expect(stream).to match_turbo_stream_snapshot("messages/new")
    end

    it "fails when content differs from the stored snapshot" do
      expect(stream).to match_turbo_stream_snapshot("messages/new")
      expect(other_stream).not_to match_turbo_stream_snapshot("messages/new")
    end

    it "accepts a response object with a body method" do
      response = double(body: stream)
      expect(response).to match_turbo_stream_snapshot("messages/new")
    end

    it "creates nested directories for the snapshot path" do
      expect(stream).to match_turbo_stream_snapshot("nested/deep/snapshot")
    end

    context "when UPDATE_TURBO_SNAPSHOTS=1" do
      around do |example|
        old = ENV["UPDATE_TURBO_SNAPSHOTS"]
        ENV["UPDATE_TURBO_SNAPSHOTS"] = "1"
        example.run
      ensure
        ENV["UPDATE_TURBO_SNAPSHOTS"] = old
      end

      it "overwrites an existing snapshot and passes" do
        expect(stream).to match_turbo_stream_snapshot("messages/new")
        expect(other_stream).to match_turbo_stream_snapshot("messages/new")
      end

      it "the updated snapshot is used on subsequent runs" do
        expect(stream).to match_turbo_stream_snapshot("messages/new")
        ENV["UPDATE_TURBO_SNAPSHOTS"] = "1"
        expect(other_stream).to match_turbo_stream_snapshot("messages/new")
        ENV["UPDATE_TURBO_SNAPSHOTS"] = nil
        expect(other_stream).to match_turbo_stream_snapshot("messages/new")
      end
    end
  end

  describe "failure messages" do
    it "shows stored and actual content on mismatch" do
      expect(stream).to match_turbo_stream_snapshot("messages/new")
      m = match_turbo_stream_snapshot("messages/new")
      m.matches?(other_stream)
      expect(m.failure_message).to include("stored").and include("actual")
      expect(m.failure_message).to include("UPDATE_TURBO_SNAPSHOTS")
    end

    it "provides negated failure message" do
      m = match_turbo_stream_snapshot("messages/new")
      expect(m.failure_message_when_negated).to include("not to match")
    end
  end

  describe "#description" do
    it "includes the snapshot name" do
      expect(match_turbo_stream_snapshot("messages/new").description).to include("messages/new")
    end
  end
end
