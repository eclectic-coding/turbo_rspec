## [Unreleased]

### Added

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
