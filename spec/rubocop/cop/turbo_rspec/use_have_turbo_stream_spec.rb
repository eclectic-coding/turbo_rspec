# frozen_string_literal: true

require "rubocop"
require "rubocop/rspec/expect_offense"
require "rubocop/rspec/support"
require "turbo_rspec/rubocop"

RSpec.describe RuboCop::Cop::TurboRspec::UseHaveTurboStream, :config do
  include RuboCop::RSpec::ExpectOffense

  it "registers an offense for response.body include with turbo-stream string" do
    expect_offense(<<~RUBY)
      expect(response.body).to include("<turbo-stream")
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(response).to have_turbo_stream` instead of asserting on `response.body` directly.
    RUBY
  end

  it "registers an offense for response.body match with turbo-stream regexp" do
    expect_offense(<<~RUBY)
      expect(response.body).to match(/turbo-stream/)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(response).to have_turbo_stream` instead of asserting on `response.body` directly.
    RUBY
  end

  it "registers an offense for not_to with turbo-stream string" do
    expect_offense(<<~RUBY)
      expect(response.body).not_to include("turbo-stream")
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(response).to have_turbo_stream` instead of asserting on `response.body` directly.
    RUBY
  end

  it "does not register an offense when using have_turbo_stream" do
    expect_no_offenses(<<~RUBY)
      expect(response).to have_turbo_stream
    RUBY
  end

  it "does not register an offense for response.body with unrelated content" do
    expect_no_offenses(<<~RUBY)
      expect(response.body).to include("Hello world")
    RUBY
  end

  it "does not register an offense when subject is not response.body" do
    expect_no_offenses(<<~RUBY)
      expect(page.body).to include("<turbo-stream")
    RUBY
  end
end
