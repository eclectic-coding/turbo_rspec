# frozen_string_literal: true

RSpec.describe TurboRspec do
  describe "VERSION" do
    it "follows semantic versioning (MAJOR.MINOR.PATCH)" do
      expect(TurboRspec::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
    end
  end
end
