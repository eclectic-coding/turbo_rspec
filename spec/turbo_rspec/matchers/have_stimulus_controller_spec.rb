# frozen_string_literal: true

RSpec.describe TurboRspec::Matchers::HaveStimulusController do
  include TurboRspec::Matchers

  describe "#matches?" do
    it "matches when the controller is present" do
      expect('<div data-controller="hello"></div>').to have_stimulus_controller("hello")
    end

    it "matches when the controller is one of multiple" do
      expect('<div data-controller="hello world"></div>').to have_stimulus_controller("hello")
    end

    it "does not match when the controller is absent" do
      expect("<div></div>").not_to have_stimulus_controller("hello")
    end

    it "does not match a different controller" do
      expect('<div data-controller="world"></div>').not_to have_stimulus_controller("hello")
    end

    it "does not partial-match a controller name" do
      expect('<div data-controller="hello-world"></div>').not_to have_stimulus_controller("hello")
    end

    it "matches on a nested element" do
      expect('<section><div data-controller="hello"></div></section>').to have_stimulus_controller("hello")
    end

    it "accepts a response object with a body method" do
      response = double(body: '<div data-controller="hello"></div>')
      expect(response).to have_stimulus_controller("hello")
    end
  end

  describe "failure messages" do
    it "describes the missing controller" do
      matcher = have_stimulus_controller("hello")
      matcher.matches?("<div></div>")
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
