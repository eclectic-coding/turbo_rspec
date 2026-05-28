# turbo_rspec Roadmap

RSpec matchers for [Turbo](https://github.com/hotwired/turbo-rails): Turbo Streams, Turbo Frames, and ActionCable broadcasts. The goal is to replace the hand-rolled helpers that every Rails/Turbo project accumulates.

---

## Post-1.0 ideas (not scheduled)

- VS Code / RubyMine snippet pack for common patterns
- Playwright/Puppeteer bridge for headless assertions outside Capybara

---

## Guiding principles

- **Zero magic by default.** Auto-include only when it's unambiguous (Rails request specs). Everything else is opt-in.
- **Fail loudly with useful output.** A cryptic failure message is a bug.
- **No minitest dependency in the core.** The gem is RSpec-first; minitest support is a separate module.
- **Stay close to Turbo's own naming.** Matcher names mirror Turbo's action names so the docs cross-reference naturally.
