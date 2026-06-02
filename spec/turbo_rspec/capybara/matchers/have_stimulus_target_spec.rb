# frozen_string_literal: true

require "capybara"

RSpec.describe TurboRspec::Capybara::Matchers::HaveStimulusTarget do
  include TurboRspec::Capybara::Matchers

  def page_with(html)
    ::Capybara.string(html)
  end

  describe "#matches?" do
    it "matches when the target is present" do
      expect(page_with('<div data-hello-target="name"></div>')).to have_stimulus_target("hello", "name")
    end

    it "matches when the target is one of multiple" do
      expect(page_with('<div data-hello-target="name description"></div>')).to have_stimulus_target("hello", "name")
    end

    it "does not match when the target is absent" do
      expect(page_with("<div></div>")).not_to have_stimulus_target("hello", "name")
    end

    it "does not match a different target name" do
      expect(page_with('<div data-hello-target="description"></div>')).not_to have_stimulus_target("hello", "name")
    end

    it "does not match a different controller's target attribute" do
      expect(page_with('<div data-world-target="name"></div>')).not_to have_stimulus_target("hello", "name")
    end

    it "does not partial-match a target name" do
      expect(page_with('<div data-hello-target="nameField"></div>')).not_to have_stimulus_target("hello", "name")
    end
  end

  describe "failure messages" do
    it "describes the missing target" do
      matcher = have_stimulus_target("hello", "name")
      matcher.matches?(page_with("<div></div>"))
      expect(matcher.failure_message).to include("name").and include("hello")
    end

    it "provides negated failure message" do
      expect(have_stimulus_target("hello", "name").failure_message_when_negated).to include("not")
    end
  end

  describe "#description" do
    it "includes the controller and target names" do
      expect(have_stimulus_target("hello", "name").description).to include("hello").and include("name")
    end
  end
end
