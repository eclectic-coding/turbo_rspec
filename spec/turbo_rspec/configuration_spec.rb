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

  describe ".install_rspec_integration" do
    let(:rspec_config) { double("RSpec::Core::Configuration") }

    context "when auto_include is true and turbo-rails is present" do
      before do
        allow(Gem.loaded_specs).to receive(:key?).with("turbo-rails").and_return(true)
        allow(Gem.loaded_specs).to receive(:key?).with("capybara").and_return(false)
      end

      it "includes Matchers into request example groups" do
        expect(rspec_config).to receive(:include).with(TurboRspec::Matchers, type: :request)
        described_class.install_rspec_integration(rspec_config)
      end
    end

    context "when auto_include is true and both turbo-rails and capybara are present" do
      before do
        allow(Gem.loaded_specs).to receive(:key?).with("turbo-rails").and_return(true)
        allow(Gem.loaded_specs).to receive(:key?).with("capybara").and_return(true)
      end

      it "includes Capybara::Matchers into system and feature example groups" do
        allow(rspec_config).to receive(:include).with(TurboRspec::Matchers, type: :request)
        expect(rspec_config).to receive(:include).with(TurboRspec::Capybara::Matchers, type: :system)
        expect(rspec_config).to receive(:include).with(TurboRspec::Capybara::Matchers, type: :feature)
        described_class.install_rspec_integration(rspec_config)
      end
    end

    context "when auto_include is false" do
      before { described_class.configure { |c| c.auto_include = false } }

      it "does not include Matchers" do
        expect(rspec_config).not_to receive(:include)
        described_class.install_rspec_integration(rspec_config)
      end
    end

    context "when turbo-rails is not present" do
      before { allow(Gem.loaded_specs).to receive(:key?).with("turbo-rails").and_return(false) }

      it "does not include Matchers" do
        expect(rspec_config).not_to receive(:include)
        described_class.install_rspec_integration(rspec_config)
      end
    end
  end
end
