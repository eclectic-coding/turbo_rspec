# frozen_string_literal: true

require "fileutils"

module TurboRspec
  module Matchers
    # RSpec matcher that records a turbo stream response on the first run and
    # diffs against the stored snapshot on subsequent runs.
    #
    # Snapshots are written to the directory configured by
    # +TurboRspec.configuration.snapshot_dir+ (default: +spec/snapshots/turbo+).
    # Each snapshot is stored as +{name}.turbo+.
    #
    # Set +UPDATE_TURBO_SNAPSHOTS=1+ to overwrite existing snapshots.
    #
    # @example
    #   expect(response).to match_turbo_stream_snapshot("messages/new")
    class MatchTurboStreamSnapshot
      def initialize(name)
        @name = name
      end

      # @param response_or_body [#body, String]
      # @return [Boolean]
      def matches?(response_or_body)
        @actual = extract_body(response_or_body)
        @path = snapshot_path

        if update_snapshots? || !File.exist?(@path)
          write_snapshot(@actual)
          true
        else
          @stored = File.read(@path)
          @actual.strip == @stored.strip
        end
      end

      # @param response_or_body [#body, String]
      # @return [Boolean]
      def does_not_match?(response_or_body)
        !matches?(response_or_body)
      end

      # @return [String]
      def failure_message
        "expected response to match turbo stream snapshot #{@name.inspect}\n\n" \
          "stored:\n#{@stored}\n\n" \
          "actual:\n#{@actual}\n\n" \
          "To update: run with UPDATE_TURBO_SNAPSHOTS=1"
      end

      # @return [String]
      def failure_message_when_negated
        "expected response not to match turbo stream snapshot #{@name.inspect}"
      end

      # @return [String]
      def description
        "match turbo stream snapshot #{@name.inspect}"
      end

      private

      def extract_body(response_or_body)
        if response_or_body.respond_to?(:body)
          response_or_body.body
        else
          response_or_body.to_s
        end
      end

      def snapshot_path
        File.join(TurboRspec.configuration.snapshot_dir, "#{@name}.turbo")
      end

      def write_snapshot(content)
        FileUtils.mkdir_p(File.dirname(@path))
        File.write(@path, content)
      end

      def update_snapshots?
        ENV["UPDATE_TURBO_SNAPSHOTS"] == "1"
      end
    end
  end
end
