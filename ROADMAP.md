# turbo_rspec Roadmap

RSpec matchers for [Turbo](https://github.com/hotwired/turbo-rails): Turbo Streams, Turbo Frames, and ActionCable broadcasts. The goal is to replace the hand-rolled helpers that every Rails/Turbo project accumulates.

---

## v0.1.0 — Foundation (publish to RubyGems)

**Goal:** a minimal but useful gem that earns a place in people's `Gemfile`. Cover the most common request-spec case: asserting on a Turbo Stream response.

### Matchers

- `have_turbo_frame` — assert response contains a `<turbo-frame>` element
  - `.with_id("frame_id")`
  - `.with_content("text")` / `.rendering("partial")`

### Setup

- Auto-include matchers into `RSpec::Rails::RequestExampleGroup` when `turbo-rails` is present
- `TurboRspec.configure` block for opt-in configuration (e.g. disable auto-include)
- Explicit `include TurboRspec::Matchers` for non-Rails or custom contexts

### Gem hygiene

- Fill out `turbo_rspec.gemspec` (summary, description, homepage, source_code_uri, changelog_uri)
- Declare runtime dependency on `nokogiri` (HTML parsing) and `turbo-rails`
- Enable `rubygems_mfa_required`
- Set up GitHub Actions CI (Ruby 3.2/3.3/3.4 × Rails 7.2/8.0)
- Set up RubyGems Trusted Publishing (OIDC, no stored API key)
- Replace placeholder README with real usage docs and examples
- Replace placeholder CHANGELOG entry with real notes

---

## v0.2.0 — Broadcast matchers

**Goal:** cover the broadcast side — jobs/services that push streams over ActionCable.

- `have_broadcasted_turbo_stream_to(channel_or_object)` — wraps ActionCable's test adapter
  - Same fluent chain as `have_turbo_stream`: `.with_action`, `.targeting`, `.rendering`, `.with_content`
  - Count qualifiers: `.exactly(n).times`, `.at_least(n).times`, `.at_most(n).times`, `.once`, `.twice`
  - Works inside `expect { }.to have_broadcasted_turbo_stream_to(...)` blocks
- Helper `broadcast_turbo_stream_to` alias for symmetry with ActionCable's naming
- Docs: "testing broadcasts in job specs and service specs"

---

## v0.3.0 — Capybara / system spec integration

**Goal:** assertions that work against a live browser in feature/system specs.

- `have_turbo_frame(id)` Capybara matcher — waits for the frame to appear on the page
  - `.with_content(...)` — delegates to Capybara's `have_content` with correct scope
  - `.loaded` — asserts `[complete]` attribute is present (frame finished loading)
- `within_turbo_frame(id) { ... }` — scopes Capybara assertions to the frame's DOM
- `have_turbo_stream_tag` — asserts a `<turbo-stream-source>` subscription element exists on the page
- Docs: system spec patterns, async update testing

---

## v0.4.0 — Developer experience pass

**Goal:** make failure output good enough that you never have to drop into a debugger just to read a matcher failure.

- Rich failure messages: show actual stream actions/targets found vs. expected
- `assert_no_turbo_stream` alias for teams that mix RSpec/minitest terminology
- Composable matchers: `include(have_turbo_stream(...), have_turbo_stream(...))` for multi-stream assertions
- `have_turbo_streams` (plural) — assert multiple streams in one expectation with an array DSL
- Support for `aggregate_failures` blocks

---

## v0.5.0 — Compatibility and edge cases

**Goal:** harden the gem against real-world app variations.

- Rails 7.1/7.2/8.0/8.1 and Turbo 1.x/2.x compatibility matrix in CI
- Multi-stream response body parsing (a single response can contain multiple `<turbo-stream>` tags)
- `refresh` action support (Turbo 8 page refresh streams)
- `morph` action support (Turbo Morphing)
- Graceful no-op when `turbo-rails` is not in the Gemfile (no `LoadError`)
- Minitest module (`TurboRspec::Assertions`) as opt-in companion (no RSpec dependency for that module)

---

## v1.0.0 — Stable API

**Goal:** API freeze. Commit to semver stability. Make the gem the obvious default choice.

- API stability guarantee: no breaking changes without a major version bump
- `TurboRspec::VERSION` semantic versioning enforced via CI check
- Migration guide: "replacing hand-rolled Turbo Stream helpers" in the docs
- Full YARD documentation with `yard` and hosted on RubyDoc.info
- 100% branch coverage enforced in CI (`simplecov`)
- Performance: benchmark matcher overhead to keep it negligible in large suites
- `bin/release` script (mirrors solid_queue_web pattern): bump version, update CHANGELOG, tag, push; CI publishes via Trusted Publishing

---

## Post-1.0 ideas (not scheduled)

- VS Code / RubyMine snippet pack for common patterns
- `turbo_rspec` generator (`rails generate turbo_rspec:install`) to scaffold `spec/support/turbo.rb`
- Playwright/Puppeteer bridge for headless assertions outside Capybara
- Shared examples: `it_behaves_like "a turbo stream response"` for controller testing

---

## Guiding principles

- **Zero magic by default.** Auto-include only when it's unambiguous (Rails request specs). Everything else is opt-in.
- **Fail loudly with useful output.** A cryptic failure message is a bug.
- **No minitest dependency in the core.** The gem is RSpec-first; minitest support is a separate module.
- **Stay close to Turbo's own naming.** Matcher names mirror Turbo's action names so the docs cross-reference naturally.