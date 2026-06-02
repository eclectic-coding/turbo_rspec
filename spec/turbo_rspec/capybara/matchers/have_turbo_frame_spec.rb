# frozen_string_literal: true

require "capybara"

RSpec.describe TurboRspec::Capybara::Matchers::HaveTurboFrame do
  include TurboRspec::Capybara::Matchers

  def page_with(html)
    ::Capybara.string(html)
  end

  def turbo_frame(id: "my-frame", content: nil, complete: false, src: nil, loading: nil, strict: nil)
    attrs = complete ? ' complete="complete"' : ""
    attrs += " src=\"#{src}\"" if src
    attrs += " strict=\"#{strict}\"" unless strict.nil?
    attrs += " loading=\"#{loading}\"" if loading
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

    it "matches with src" do
      expect(page_with(turbo_frame(src: "/partial"))).to have_turbo_frame("my-frame").with_src("/partial")
    end

    it "does not match when src differs" do
      expect(page_with(turbo_frame(src: "/other"))).not_to have_turbo_frame("my-frame").with_src("/partial")
    end

    it "does not match with_src when src is absent" do
      expect(page_with(turbo_frame)).not_to have_turbo_frame("my-frame").with_src("/partial")
    end

    it "matches lazy frame" do
      expect(page_with(turbo_frame(loading: "lazy"))).to have_turbo_frame("my-frame").lazy
    end

    it "does not match lazy when loading attribute is absent" do
      expect(page_with(turbo_frame)).not_to have_turbo_frame("my-frame").lazy
    end

    it "chains lazy and with_src" do
      expect(page_with(turbo_frame(src: "/partial", loading: "lazy")))
        .to have_turbo_frame("my-frame").lazy.with_src("/partial")
    end

    it "matches eager frame" do
      expect(page_with(turbo_frame(loading: "eager"))).to have_turbo_frame("my-frame").eager
    end

    it "does not match eager when loading attribute is absent" do
      expect(page_with(turbo_frame)).not_to have_turbo_frame("my-frame").eager
    end

    it "does not match eager when loading is lazy" do
      expect(page_with(turbo_frame(loading: "lazy"))).not_to have_turbo_frame("my-frame").eager
    end

    it "matches strict frame" do
      expect(page_with(turbo_frame(strict: ""))).to have_turbo_frame("my-frame").strict
    end

    it "does not match strict when strict attribute is absent" do
      expect(page_with(turbo_frame)).not_to have_turbo_frame("my-frame").strict
    end

    it "chains eager and strict" do
      expect(page_with(turbo_frame(loading: "eager", strict: "")))
        .to have_turbo_frame("my-frame").eager.strict
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

    it "describes missing src" do
      matcher = have_turbo_frame("my-frame").with_src("/partial")
      matcher.matches?(page_with(turbo_frame(src: "/other")))
      expect(matcher.failure_message).to include("/partial").and include("/other")
    end

    it "describes missing lazy attribute" do
      matcher = have_turbo_frame("my-frame").lazy
      matcher.matches?(page_with(turbo_frame))
      expect(matcher.failure_message).to include("lazy")
    end

    it "describes missing eager attribute" do
      matcher = have_turbo_frame("my-frame").eager
      matcher.matches?(page_with(turbo_frame))
      expect(matcher.failure_message).to include("eager")
    end

    it "describes missing strict attribute" do
      matcher = have_turbo_frame("my-frame").strict
      matcher.matches?(page_with(turbo_frame))
      expect(matcher.failure_message).to include("strict")
    end
  end

  describe "#description" do
    it "includes the frame id" do
      expect(have_turbo_frame("my-frame").description).to include("my-frame")
    end

    it "includes loaded constraint" do
      expect(have_turbo_frame("my-frame").loaded.description).to include("loaded")
    end

    it "includes lazy constraint" do
      expect(have_turbo_frame("my-frame").lazy.description).to include("lazy")
    end

    it "includes eager constraint" do
      expect(have_turbo_frame("my-frame").eager.description).to include("eager")
    end

    it "includes strict constraint" do
      expect(have_turbo_frame("my-frame").strict.description).to include("strict")
    end

    it "includes src constraint" do
      expect(have_turbo_frame("my-frame").with_src("/partial").description).to include("/partial")
    end

    it "includes content constraint" do
      expect(have_turbo_frame("my-frame").with_content("Hello").description).to include("Hello")
    end
  end
end
