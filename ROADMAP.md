# turbo_rspec Roadmap

RSpec matchers for [Turbo](https://github.com/hotwired/turbo-rails): Turbo Streams, Turbo Frames, and ActionCable broadcasts. The goal is to replace the hand-rolled helpers that every Rails/Turbo project accumulates.

---

## 1.1 — Matcher parity

- **Count qualifiers on `have_turbo_stream`** — `.once`, `.twice`, `.exactly(n).times` for request specs, matching the parity already present on `have_broadcasted_turbo_stream_to`. A single response with two `append` streams is a real case that currently requires two separate expectations.
- **Capybara `have_turbo_frame` additions** — `.with_src(url)` (assert the `src` attribute of a lazy frame) and `.lazy` (assert `loading="lazy"` is set). These cover the lazy-loading pattern that's very common with Turbo Frames.

## 1.2 — Turbo 8 / morphing

- **`with_attributes(hash)` chain** — generic attribute assertion for both `have_turbo_stream` and `have_turbo_frame`. Covers non-standard attributes (e.g., `data-*` passed through custom actions) without needing new named chains per attribute.
- **Morph-aware assertions** — `morph` is a supported action but Turbo 8's `<turbo-stream action="morph">` has distinct semantics (`[children-only]` attribute). A `.children_only` chain on `have_turbo_stream` would make morph specs readable without raw attribute checks.
- **Custom Turbo action support** — Turbo 8 allows registering custom stream actions. A `TurboRspec.register_action(:sparkle)` API would let teams assert their own actions without them being treated as unknown values.

## 1.3 — Stimulus companion

- **Stimulus matchers** — `have_stimulus_controller`, `have_stimulus_action`, `have_stimulus_target` Capybara matchers. turbo-rails ships with Stimulus; teams using both already test Stimulus behavior manually. This is the natural next surface area for a complete Hotwire testing toolkit.

## 1.4 — Tooling

- **RuboCop cop** — flag request specs that assert `response.body` with a raw string match or `include "<turbo-stream"` instead of using the gem's matchers. Useful for migration and incremental adoption.
- **Snapshot/fixture matcher** — `match_turbo_stream_snapshot("name")` records the stream on the first run and diffs on subsequent runs. Good for complex multi-stream responses where re-specifying every constraint in detail is noisy.

---

## Guiding principles

- **Zero magic by default.** Auto-include only when it's unambiguous (Rails request specs). Everything else is opt-in.
- **Fail loudly with useful output.** A cryptic failure message is a bug.
- **No minitest dependency in the core.** The gem is RSpec-first; minitest support is a separate module.
- **Stay close to Turbo's own naming.** Matcher names mirror Turbo's action names so the docs cross-reference naturally.