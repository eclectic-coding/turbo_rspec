# turbo_rspec Roadmap

RSpec matchers for [Turbo](https://github.com/hotwired/turbo-rails): Turbo Streams, Turbo Frames, and ActionCable broadcasts. The goal is to replace the hand-rolled helpers that every Rails/Turbo project accumulates.

## 1.5 — Broadcast parity & DX

- **`with_action` validation on `have_broadcasted_turbo_stream_to`** — `have_turbo_stream.with_action` raises `ArgumentError` for unknown actions; the broadcast matcher silently accepts anything. Closing this gap means a typo in a broadcast spec fails at the assertion call rather than producing a confusing "no matching broadcasts" message.
- **`.children_only` and `.with_attributes` on `have_broadcasted_turbo_stream_to`** — Both chains exist on `have_turbo_stream`; morph broadcasts with `children-only` and custom attributes are real patterns that currently can't be asserted cleanly.
- **Richer broadcast failure messages** — When a broadcast match fails, show what was actually broadcast to the stream (action, target, content preview), mirroring the closest-match diff already present in the request-spec matcher.
- **Snapshot inline diff** — `match_turbo_stream_snapshot` currently dumps raw before/after strings on mismatch; a line-by-line diff makes it far easier to spot what changed.

## 1.6 — Minitest & Turbo 8 extensions

- **`assert_broadcasted_turbo_stream_to` / `refute_broadcasted_turbo_stream_to`** — `TurboRspec::Assertions` covers request-spec stream and frame assertions but has no broadcast counterpart. Teams using Minitest with ActionCable have no parity with the RSpec broadcast matcher.
- **`have_turbo_frame` Capybara `.eager` and `.strict` chains** — `.lazy` is already supported; Turbo 8 also added `loading="eager"` and a `[strict]` boolean attribute for strict frame loading. Both are missing from the Capybara matcher.
- **Stimulus request-spec matchers** — `have_stimulus_controller`, `have_stimulus_action`, and `have_stimulus_target` currently only work in Capybara system/feature specs. Teams writing request specs can't assert Stimulus attributes on rendered HTML responses without dropping to raw string matching.

---

## Guiding principles

- **Zero magic by default.** Auto-include only when it's unambiguous (Rails request specs). Everything else is opt-in.
- **Fail loudly with useful output.** A cryptic failure message is a bug.
- **No minitest dependency in the core.** The gem is RSpec-first; minitest support is a separate module.
- **Stay close to Turbo's own naming.** Matcher names mirror Turbo's action names so the docs cross-reference naturally.
