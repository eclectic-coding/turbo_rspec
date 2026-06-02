# turbo_rspec Roadmap

RSpec matchers for [Turbo](https://github.com/hotwired/turbo-rails): Turbo Streams, Turbo Frames, and ActionCable broadcasts. The goal is to replace the hand-rolled helpers that every Rails/Turbo project accumulates.

---

## 1.4 — Tooling

- **RuboCop cop** — flag request specs that assert `response.body` with a raw string match or `include "<turbo-stream"` instead of using the gem's matchers. Useful for migration and incremental adoption.
- **Snapshot/fixture matcher** — `match_turbo_stream_snapshot("name")` records the stream on the first run and diffs on subsequent runs. Good for complex multi-stream responses where re-specifying every constraint in detail is noisy.

---

## Guiding principles

- **Zero magic by default.** Auto-include only when it's unambiguous (Rails request specs). Everything else is opt-in.
- **Fail loudly with useful output.** A cryptic failure message is a bug.
- **No minitest dependency in the core.** The gem is RSpec-first; minitest support is a separate module.
- **Stay close to Turbo's own naming.** Matcher names mirror Turbo's action names so the docs cross-reference naturally.
