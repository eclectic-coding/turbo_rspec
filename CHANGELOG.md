## [Unreleased]

### Added

- `have_turbo_stream` matcher for asserting `<turbo-stream>` elements in response bodies
  - `.with_action(action)` — assert a specific action (append, prepend, replace, update, remove, before, after, refresh)
  - `.targeting(dom_id)` — assert a specific `target` attribute
  - `.targeting_all(selector)` — assert a specific `targets` CSS selector attribute
  - `.with_content(text)` — assert literal text content inside the stream element
  - `.rendering(partial)` — assert a rendered partial within the stream element
  - Negation via `not_to have_turbo_stream` works out of the box
