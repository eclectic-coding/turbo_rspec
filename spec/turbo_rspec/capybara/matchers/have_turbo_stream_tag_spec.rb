# frozen_string_literal: true

require "capybara"

RSpec.describe TurboRspec::Capybara::Matchers::HaveTurboStreamTag do
  include TurboRspec::Capybara::Matchers

  def page_with(html)
    ::Capybara.string(html)
  end

  describe "#matches?" do
    it "matches when a turbo-stream-source is present" do
      expect(page_with('<turbo-stream-source src="/cable"></turbo-stream-source>'))
        .to have_turbo_stream_tag
    end

    it "does not match when no turbo-stream-source is present" do
      expect(page_with("<div></div>")).not_to have_turbo_stream_tag
    end

    it "matches by signed stream name" do
      expect(page_with('<turbo-stream-source src="/cable?stream=abc123"></turbo-stream-source>'))
        .to have_turbo_stream_tag("abc123")
    end

    it "does not match a different signed stream name" do
      expect(page_with('<turbo-stream-source src="/cable?stream=abc123"></turbo-stream-source>'))
        .not_to have_turbo_stream_tag("other")
    end
  end

  describe "failure messages" do
    it "describes missing stream tag" do
      matcher = have_turbo_stream_tag
      matcher.matches?(page_with("<div></div>"))
      expect(matcher.failure_message).to include("turbo-stream-source")
    end

    it "includes stream name in failure message" do
      matcher = have_turbo_stream_tag("abc123")
      matcher.matches?(page_with("<div></div>"))
      expect(matcher.failure_message).to include("abc123")
    end

    it "provides negated failure message" do
      expect(have_turbo_stream_tag.failure_message_when_negated).to include("not to have")
    end
  end

  describe "#description" do
    it "describes the matcher" do
      expect(have_turbo_stream_tag.description).to include("turbo-stream-source")
    end

    it "includes stream name in description" do
      expect(have_turbo_stream_tag("abc123").description).to include("abc123")
    end
  end
end
