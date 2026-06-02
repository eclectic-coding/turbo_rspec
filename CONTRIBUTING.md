# Contributing to turbo_rspec

Bug reports and pull requests are welcome. This guide covers everything you need to get up and running.

## Setup

```bash
git clone https://github.com/eclectic-coding/turbo_rspec.git
cd turbo_rspec
bin/setup          # installs gems and wires up the pre-push hook
```

## Running the suite

```bash
bundle exec rake                        # full suite: lint + tests (what CI runs)
bundle exec rspec                       # tests only
bundle exec rspec spec/path/to/foo_spec.rb       # single file
bundle exec rspec spec/path/to/foo_spec.rb:42    # single example
bundle exec standardrb --no-fix        # lint only
```

CI requires **100% line and branch coverage** — SimpleCov will exit non-zero if either drops below that threshold.

## Branch workflow

Always work on a feature or chore branch — never commit directly to `main`:

```
feat/short-description    # new matchers, new API
chore/short-description   # docs, tooling, dependency bumps
fix/short-description     # bug fixes
```

## CHANGELOG

Add an entry under `## [Unreleased]` **on your branch before opening a PR**, not after merging. Use these section headers in order (omit any that have no entries):

```markdown
### Added
### Changed
### Fixed
```

CHANGELOG entries are **user-facing only** — document changes to the public API. Pure internal refactors, docs updates, and CI fixes don't need an entry.

## Pre-push hook

`bin/setup` installs a pre-push hook that runs automatically on every push:

- **Blocks** the push if `lib/` files changed but `CHANGELOG.md` has no new entry under `## [Unreleased]`.
- **Warns** (advisory, doesn't block) if `README.md` or `ROADMAP.md` look untouched.

To bypass when the push genuinely doesn't need a CHANGELOG entry (tooling-only changes):

```bash
git push --no-verify
```

## Pull requests

1. Open a PR against `main`.
2. All CI checks must pass: lint, security audit, and the full test matrix (Ruby 3.3–4.0 × Rails 7.2–8.1).
3. Link the relevant GitHub issue in the PR description (`Closes #N`).

## Code conventions

- **StandardRB** enforces style — run `bundle exec rake standard:fix` to auto-correct before pushing.
- Match the surrounding style for failure messages: use `✓`/`✗` indicators and a "closest match" section when showing constraint diffs.
- New public methods need YARD `@param` and `@return` tags, and an entry in `sig/turbo_rspec.rbs`.
- Private helpers don't need YARD docs.

## Custom Turbo actions

If a spec needs to assert a custom Turbo stream action, register it in the test setup rather than using `--no-verify` to bypass the `ArgumentError`:

```ruby
before { TurboRspec.register_action(:my_action) }
after  { TurboRspec.reset_configuration! }
```

## Releasing (maintainers only)

Releases are cut from `main` using the release script:

```bash
bin/release 1.2.0
```

This bumps the version, updates `CHANGELOG.md` and `Gemfile.lock`, commits, tags, and pushes. CI picks up the tag and publishes to RubyGems via Trusted Publishing.