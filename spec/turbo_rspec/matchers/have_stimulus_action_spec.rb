# frozen_string_literal: true

RSpec.describe TurboRspec::Matchers::HaveStimulusAction do
  include TurboRspec::Matchers

  describe "#matches?" do
    it "matches a full action descriptor" do
      expect('<div data-action="click->hello#greet"></div>').to have_stimulus_action("click->hello#greet")
    end

    it "matches when the action is one of multiple" do
      expect('<div data-action="click->hello#greet keyup->hello#search"></div>')
        .to have_stimulus_action("click->hello#greet")
    end

    it "matches a shorthand descriptor without an event" do
      expect('<div data-action="click->hello#greet"></div>').to have_stimulus_action("hello#greet")
    end

    it "does not match when the action is absent" do
      expect("<div></div>").not_to have_stimulus_action("click->hello#greet")
    end

    it "does not match a different action" do
      expect('<div data-action="click->hello#greet"></div>').not_to have_stimulus_action("click->hello#other")
    end

    it "does not match a full descriptor when only a different event is present" do
      expect('<div data-action="keyup->hello#greet"></div>').not_to have_stimulus_action("click->hello#greet")
    end

    it "accepts a response object with a body method" do
      response = double(body: '<div data-action="click->hello#greet"></div>')
      expect(response).to have_stimulus_action("click->hello#greet")
    end
  end

  describe "failure messages" do
    it "describes the missing action" do
      matcher = have_stimulus_action("click->hello#greet")
      matcher.matches?("<div></div>")
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
