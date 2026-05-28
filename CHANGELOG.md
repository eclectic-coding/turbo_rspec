## [Unreleased]

## [0.6.0] - 2026-05-28

### Added

- `TurboRspec::Helpers` module with `turbo_stream_html` and `turbo_frame_html` factory helpers for building test HTML inline
- Shared examples: `it_behaves_like "a turbo stream response"` and `it_behaves_like "a turbo frame response"` for common assertions
- `have_turbo_stream`, `have_turbo_frame`, and `TurboRspec::Helpers` auto-included into `type: :controller` example groups alongside `type: :request`

## [0.5.0] - 2026-05-28

### Added

- `TurboRspec::Assertions` — opt-in minitest companion module with `assert_turbo_stream`, `refute_turbo_stream`, `assert_turbo_frame`, `refute_turbo_frame`; no RSpec dependency required
- `refresh` and `morph` action support confirmed working via compatibility specs
- Multi-stream response body parsing confirmed — a single response body with multiple `<turbo-stream>` tags works with all matchers
- Graceful no-op when `turbo-rails` is not in the Gemfile — no `LoadError`
- CI Rails matrix: Ruby 3.3/3.4/4.0 × Rails 7.2/8.0/8.1

## [0.4.0] - 2026-05-28

### Added

- `have_turbo_streams(*matchers)` — assert multiple streams in one expectation; failure lists each unmatched stream
- `assert_no_turbo_stream` — alias of `have_turbo_stream` for teams that mix RSpec/minitest terminology
- Rich failure messages for `have_turbo_stream` and `have_turbo_frame`: content preview on each found element, plus a "closest match" section with per-constraint pass (✓) / fail (✗) indicators

## [0.3.0] - 2026-05-28

### Added

- `have_turbo_frame(id)` Capybara matcher for system/feature specs — asserts a `<turbo-frame>` element is on the page
  - `.with_content(text)` — asserts text content within the frame
  - `.loaded` — asserts the frame has the `[complete]` attribute (finished loading)
- `have_turbo_stream_tag` Capybara matcher — asserts a `<turbo-stream-source>` subscription element is present; accepts an optional signed stream name
- `within_turbo_frame(id) { }` — scopes Capybara assertions to the frame's DOM
- Auto-include `TurboRspec::Capybara::Matchers` into `type: :system` and `type: :feature` example groups when both `turbo-rails` and `capybara` are present

## [0.2.0] - 2026-05-28

### Added

- `have_broadcasted_turbo_stream_to(stream)` block matcher for asserting ActionCable broadcasts contain a `<turbo-stream>` element
  - Same fluent chain as `have_turbo_stream`: `.with_action`, `.targeting`, `.targeting_all`, `.with_content`, `.rendering`
  - Count qualifiers: `.once`, `.twice`, `.exactly(n).times`, `.at_least(n).times`, `.at_most(n).times`
  - `broadcast_turbo_stream_to` alias for naming symmetry with ActionCable's API
  - Negation via `not_to have_broadcasted_turbo_stream_to` works out of the box

## [0.1.0] - 2026-05-28

### Added

- Real usage README covering both matchers, setup, and configuration
- `TurboRspec.configure` block for opt-in configuration
- Auto-include `TurboRspec::Matchers` into `RSpec::Rails` request example groups when `turbo-rails` is present; disable with `TurboRspec.configure { |c| c.auto_include = false }`
- Explicit `include TurboRspec::Matchers` supported in any non-Rails or custom context
- `have_turbo_frame` matcher for asserting `<turbo-frame>` elements in response bodies
  - `.with_id(id)` — assert a specific `id` attribute
  - `.with_content(text)` — assert literal text content inside the frame element
  - `.rendering(partial)` — assert a rendered partial within the frame element
  - Negation via `not_to have_turbo_frame` works out of the box
- `have_turbo_stream` matcher for asserting `<turbo-stream>` elements in response bodies
  - `.with_action(action)` — assert a specific action (append, prepend, replace, update, remove, before, after, refresh)
  - `.targeting(dom_id)` — assert a specific `target` attribute
  - `.targeting_all(selector)` — assert a specific `targets` CSS selector attribute
  - `.with_content(text)` — assert literal text content inside the stream element
  - `.rendering(partial)` — assert a rendered partial within the stream element
  - Negation via `not_to have_turbo_stream` works out of the box
