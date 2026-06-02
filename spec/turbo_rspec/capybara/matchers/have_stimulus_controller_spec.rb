# frozen_string_literal: true

require "capybara"

RSpec.describe TurboRspec::Capybara::Matchers::HaveStimulusController do
  include TurboRspec::Capybara::Matchers

  def page_with(html)
    ::Capybara.string(html)
  end

  describe "#matches?" do
    it "matches when the controller is present" do
      expect(page_with('<div data-controller="hello"></div>')).to have_stimulus_controller("hello")
    end

    it "matches when the controller is one of multiple" do
      expect(page_with('<div data-controller="hello world"></div>')).to have_stimulus_controller("hello")
    end

    it "does not match when the controller is absent" do
      expect(page_with("<div></div>")).not_to have_stimulus_controller("hello")
    end

    it "does not match a different controller" do
      expect(page_with('<div data-controller="world"></div>')).not_to have_stimulus_controller("hello")
    end

    it "does not partial-match a controller name" do
      expect(page_with('<div data-controller="hello-world"></div>')).not_to have_stimulus_controller("hello")
    end

    it "matches on a nested element" do
      expect(page_with('<section><div data-controller="hello"></div></section>')).to have_stimulus_controller("hello")
    end
  end

  describe "failure messages" do
    it "describes the missing controller" do
      matcher = have_stimulus_controller("hello")
      matcher.matches?(page_with("<div></div>"))
      expect(matcher.failure_message).to include("hello")
    end

    it "provides negated failure message" do
      expect(have_stimulus_controller("hello").failure_message_when_negated).to include("not")
    end
  end

  describe "#description" do
    it "includes the controller name" do
      expect(have_stimulus_controller("hello").description).to include("hello")
    end
  end
end
