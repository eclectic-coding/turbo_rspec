## [Unreleased]

### Added

- `match_turbo_stream_snapshot` failure message now shows a line-by-line inline diff (stored → actual) instead of raw before/after strings
- `have_broadcasted_turbo_stream_to` failure message now lists all streams broadcast to the channel and shows a closest-match diff with per-constraint ✓/✗ indicators — mirrors the behaviour already present in `have_turbo_stream`
- `have_broadcasted_turbo_stream_to` now validates action names via `TurboRspec.known_actions`, raising `ArgumentError` for unrecognised actions — consistent with `have_turbo_stream`
- `have_broadcasted_turbo_stream_to.with_attributes(hash)` — assert arbitrary HTML attributes on broadcast stream elements
- `have_broadcasted_turbo_stream_to.children_only` — assert the `[children-only]` attribute on morph broadcasts

## [1.4.0] - 2026-06-02

### Added

- `match_turbo_stream_snapshot(name)` — records the turbo stream response on the first run and diffs against it on subsequent runs; set `UPDATE_TURBO_SNAPSHOTS=1` to overwrite
- `TurboRspec::Cop::UseHaveTurboStream` RuboCop cop — flags `expect(response.body).to include("<turbo-stream")` and similar raw-body patterns; load via `require "turbo_rspec/rubocop"` in `.rubocop.yml`
- `TurboRspec.configuration.snapshot_dir` — configure snapshot storage path (default: `spec/snapshots/turbo`)

## [1.3.0] - 2026-06-02

### Added

- `have_stimulus_controller(name)` — Capybara matcher asserting `data-controller` contains the given controller name
- `have_stimulus_action(descriptor)` — Capybara matcher asserting `data-action` contains the descriptor; accepts a full descriptor (`click->hello#greet`) or shorthand without event (`hello#greet`)
- `have_stimulus_target(controller, target)` — Capybara matcher asserting `data-{controller}-target` contains the target name

## [1.2.0] - 2026-06-01

### Added

- `have_turbo_stream.with_attributes(hash)` — assert arbitrary HTML attributes on a stream element; accepts string or symbol keys
- `have_turbo_frame.with_attributes(hash)` — same for frame elements in request specs
- `have_turbo_stream.children_only` — assert the `children-only` attribute on Turbo 8 morph streams
- `TurboRspec.register_action(:name)` — declare custom Turbo stream actions; `with_action` now raises `ArgumentError` for unrecognised actions with a hint to register them
- `TurboRspec::BUILTIN_ACTIONS` — public constant listing all built-in action names
- `TurboRspec.known_actions` — returns built-in + registered custom actions

## [1.1.0] - 2026-06-01

### Added

- Count qualifiers on `have_turbo_stream`: `.once`, `.twice`, `.exactly(n).times`, `.at_least(n).times`, `.at_most(n).times` — mirrors the API already available on `have_broadcasted_turbo_stream_to`
- `have_turbo_frame` (Capybara) `.with_src(url)` chain — asserts the `src` attribute of a lazy-loaded frame
- `have_turbo_frame` (Capybara) `.lazy` chain — asserts `loading="lazy"` is set on the frame

## [1.0.0] - 2026-05-28

### Added

- `rails generate turbo_rspec:install` — scaffolds `spec/support/turbo_rspec.rb` with sensible defaults
- `bin/benchmark` — measures matcher overhead against a 100-element response body
- Semver format enforced via spec (`TurboRspec::VERSION` must match `MAJOR.MINOR.PATCH`)
- SimpleCov minimum coverage enforced: 100% line and branch required for CI to pass

## [0.7.0] - 2026-05-28

### Added

- Full YARD documentation on all public methods, classes, and modules
- `docs/migration_guide.md` — how to replace hand-rolled Turbo helpers with `turbo_rspec` matchers
- `docs/cookbook.md` — common patterns: request specs, lazy frames, broadcast job specs, multi-stream responses, Minitest, controller specs

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
