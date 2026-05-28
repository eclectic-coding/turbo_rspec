# turbo_rspec Roadmap

RSpec matchers for [Turbo](https://github.com/hotwired/turbo-rails): Turbo Streams, Turbo Frames, and ActionCable broadcasts. The goal is to replace the hand-rolled helpers that every Rails/Turbo project accumulates.

---

## v0.7.0 — Documentation

**Goal:** full docs before freezing the API.

- Full YARD documentation on all public methods and classes
- Migration guide: "replacing hand-rolled Turbo helpers in your test suite"
- Cookbook: common patterns (lazy-loaded frames, job broadcast testing, multi-stream responses, controller specs)

---

## v1.0.0 — Stable API

**Goal:** API freeze. Commit to semver stability. Make the gem the obvious default choice.

- API stability guarantee: no breaking changes without a major version bump
- `TurboRspec::VERSION` semantic versioning enforced via CI check
- 100% branch coverage enforced in CI (`simplecov`)
- Performance: benchmark matcher overhead to keep it negligible in large suites
- `bin/release` script (mirrors solid_queue_web pattern): bump version, update CHANGELOG, tag, push; CI publishes via Trusted Publishing
- `turbo_rspec` generator (`rails generate turbo_rspec:install`) to scaffold `spec/support/turbo.rb`

---

## Post-1.0 ideas (not scheduled)

- VS Code / RubyMine snippet pack for common patterns
- Playwright/Puppeteer bridge for headless assertions outside Capybara
- Shared examples: `it_behaves_like "a turbo stream response"` for controller testing

---

## Guiding principles

- **Zero magic by default.** Auto-include only when it's unambiguous (Rails request specs). Everything else is opt-in.
- **Fail loudly with useful output.** A cryptic failure message is a bug.
- **No minitest dependency in the core.** The gem is RSpec-first; minitest support is a separate module.
- **Stay close to Turbo's own naming.** Matcher names mirror Turbo's action names so the docs cross-reference naturally.
