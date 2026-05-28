# frozen_string_literal: true

RSpec.describe TurboRspec::Configuration do
  subject(:config) { described_class.new }

  it "enables auto_include by default" do
    expect(config.auto_include).to be true
  end

  it "allows auto_include to be disabled" do
    config.auto_include = false
    expect(config.auto_include).to be false
  end
end

RSpec.describe TurboRspec do
  after { described_class.reset_configuration! }

  describe ".configure" do
    it "yields the configuration object" do
      described_class.configure do |config|
        expect(config).to be_a(TurboRspec::Configuration)
      end
    end

    it "persists changes made in the block" do
      described_class.configure { |c| c.auto_include = false }
      expect(described_class.configuration.auto_include).to be false
    end
  end

  describe ".configuration" do
    it "returns the same instance on repeated calls" do
      expect(described_class.configuration).to be(described_class.configuration)
    end
  end

  describe ".reset_configuration!" do
    it "resets to defaults" do
      described_class.configure { |c| c.auto_include = false }
      described_class.reset_configuration!
      expect(described_class.configuration.auto_include).to be true
    end
  end
end
