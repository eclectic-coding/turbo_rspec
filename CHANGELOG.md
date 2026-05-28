## [Unreleased]

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
