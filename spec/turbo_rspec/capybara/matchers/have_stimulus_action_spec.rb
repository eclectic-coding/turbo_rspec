# frozen_string_literal: true

require "capybara"

RSpec.describe TurboRspec::Capybara::Matchers::HaveStimulusAction do
  include TurboRspec::Capybara::Matchers

  def page_with(html)
    ::Capybara.string(html)
  end

  describe "#matches?" do
    it "matches a full action descriptor" do
      expect(page_with('<div data-action="click->hello#greet"></div>')).to have_stimulus_action("click->hello#greet")
    end

    it "matches when the action is one of multiple" do
      expect(page_with('<div data-action="click->hello#greet keyup->hello#search"></div>'))
        .to have_stimulus_action("click->hello#greet")
    end

    it "matches a shorthand descriptor without an event" do
      expect(page_with('<div data-action="click->hello#greet"></div>')).to have_stimulus_action("hello#greet")
    end

    it "does not match when the action is absent" do
      expect(page_with("<div></div>")).not_to have_stimulus_action("click->hello#greet")
    end

    it "does not match a different action" do
      expect(page_with('<div data-action="click->hello#greet"></div>')).not_to have_stimulus_action("click->hello#other")
    end

    it "does not match with a full descriptor when only shorthand is present" do
      expect(page_with('<div data-action="keyup->hello#greet"></div>')).not_to have_stimulus_action("click->hello#greet")
    end
  end

  describe "failure messages" do
    it "describes the missing action" do
      matcher = have_stimulus_action("click->hello#greet")
      matcher.matches?(page_with("<div></div>"))
      expect(matcher.failure_message).to include("click->hello#greet")
    end

    it "provides negated failure message" do
      expect(have_stimulus_action("click->hello#greet").failure_message_when_negated).to include("not")
    end
  end

  describe "#description" do
    it "includes the action descriptor" do
      expect(have_stimulus_action("click->hello#greet").description).to include("click->hello#greet")
    end
  end
end