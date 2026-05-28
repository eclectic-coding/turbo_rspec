# frozen_string_literal: true

require_relative "lib/turbo_rspec/version"

Gem::Specification.new do |spec|
  spec.name = "turbo_rspec"
  spec.version = TurboRspec::VERSION
  spec.authors = ["Chuck Smith"]
  spec.email = ["eclectic-coding@users.noreply.github.com"]

  spec.summary = "RSpec matchers for Turbo Streams, Turbo Frames, and ActionCable broadcasts."
  spec.description = "Drop-in RSpec matchers for hotwired/turbo-rails: assert Turbo Stream responses, Turbo Frame content, and ActionCable broadcasts without hand-rolling helpers in every project."
  spec.homepage = "https://github.com/eclectic-coding/turbo_rspec"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/eclectic-coding/turbo_rspec"
  spec.metadata["changelog_uri"] = "https://github.com/eclectic-coding/turbo_rspec/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .standard.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", ">= 1.13"

  # For more information and examples about making a new gem, check out our
  # guide at: https://guides.rubygems.org/make-your-own-gem/
end
