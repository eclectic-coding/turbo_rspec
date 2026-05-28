# frozen_string_literal: true

require "capybara"

RSpec.describe TurboRspec::Capybara::Matchers::HaveTurboFrame do
  include TurboRspec::Capybara::Matchers

  def page_with(html)
    ::Capybara.string(html)
  end

  def turbo_frame(id: "my-frame", content: nil, complete: false)
    attrs = complete ? ' complete="complete"' : ""
    inner = content || ""
    "<turbo-frame id=\"#{id}\"#{attrs}>#{inner}</turbo-frame>"
  end

  describe "#matches?" do
    it "matches when the frame is present" do
      expect(page_with(turbo_frame)).to have_turbo_frame("my-frame")
    end

    it "does not match when the frame is absent" do
      expect(page_with("<div></div>")).not_to have_turbo_frame("my-frame")
    end

    it "does not match a frame with a different id" do
      expect(page_with(turbo_frame(id: "other"))).not_to have_turbo_frame("my-frame")
    end

    it "matches with content" do
      expect(page_with(turbo_frame(content: "Hello"))).to have_turbo_frame("my-frame").with_content("Hello")
    end

    it "does not match when content is missing" do
      expect(page_with(turbo_frame(content: "Hello"))).not_to have_turbo_frame("my-frame").with_content("Goodbye")
    end

    it "matches a loaded frame" do
      expect(page_with(turbo_frame(complete: true))).to have_turbo_frame("my-frame").loaded
    end

    it "does not match an unloaded frame with .loaded" do
      expect(page_with(turbo_frame(complete: false))).not_to have_turbo_frame("my-frame").loaded
    end

    it "chains loaded and with_content" do
      expect(page_with(turbo_frame(content: "Hi", complete: true)))
        .to have_turbo_frame("my-frame").loaded.with_content("Hi")
    end
  end

  describe "failure messages" do
    it "describes missing frame" do
      matcher = have_turbo_frame("my-frame")
      matcher.matches?(page_with("<div></div>"))
      expect(matcher.failure_message).to include("my-frame").and include("not found")
    end

    it "describes unloaded frame" do
      matcher = have_turbo_frame("my-frame").loaded
      matcher.matches?(page_with(turbo_frame(complete: false)))
      expect(matcher.failure_message).to include("loaded")
    end

    it "describes missing content" do
      matcher = have_turbo_frame("my-frame").with_content("Hello")
      matcher.matches?(page_with(turbo_frame(content: "other")))
      expect(matcher.failure_message).to include("Hello")
    end

    it "provides negated failure message" do
      matcher = have_turbo_frame("my-frame")
      expect(matcher.failure_message_when_negated).to include("not to have")
    end
  end

  describe "#description" do
    it "includes the frame id" do
      expect(have_turbo_frame("my-frame").description).to include("my-frame")
    end

    it "includes loaded constraint" do
      expect(have_turbo_frame("my-frame").loaded.description).to include("loaded")
    end

    it "includes content constraint" do
      expect(have_turbo_frame("my-frame").with_content("Hello").description).to include("Hello")
    end
  end
end
