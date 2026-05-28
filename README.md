# TurboRspec

[![CI](https://github.com/eclectic-coding/turbo_rspec/actions/workflows/ci.yml/badge.svg)](https://github.com/eclectic-coding/turbo_rspec/actions/workflows/ci.yml)
[![Gem Version](https://img.shields.io/gem/v/turbo_rspec)](https://rubygems.org/gems/turbo_rspec)
[![Gem Downloads](https://img.shields.io/gem/dt/turbo_rspec)](https://rubygems.org/gems/turbo_rspec)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.3-ruby)](https://rubygems.org/gems/turbo_rspec)
[![codecov](https://codecov.io/gh/eclectic-coding/turbo_rspec/branch/main/graph/badge.svg)](https://codecov.io/gh/eclectic-coding/turbo_rspec)

RSpec matchers for [Turbo](https://github.com/hotwired/turbo-rails) — assert Turbo Stream responses, Turbo Frame content, and ActionCable broadcasts without hand-rolling helpers in every project.

**Docs:** [API Reference](https://rubydoc.info/gems/turbo_rspec) · [Migration Guide](docs/migration_guide.md) · [Cookbook](docs/cookbook.md)

## Installation

Add to your application's `Gemfile`:

```ruby
group :test do
  gem "turbo_rspec"
end
```

## Setup

### Generator

Run the install generator to scaffold a `spec/support/turbo_rspec.rb` configuration file:

```bash
rails generate turbo_rspec:install
```

### Rails + turbo-rails (automatic)

No setup needed. When `turbo-rails` is in your bundle:

- `TurboRspec::Matchers` is automatically included in all `type: :request` example groups
- `TurboRspec::Capybara::Matchers` is automatically included in all `type: :system` and `type: :feature` example groups when `capybara` is also present

### Manual include

For non-Rails projects or custom contexts, include the matchers explicitly:

```ruby
# spec/spec_helper.rb
RSpec.configure do |config|
  config.include TurboRspec::Matchers                 # request specs
  config.include TurboRspec::Capybara::Matchers       # system/feature specs
end
```

### Configuration

```ruby
# spec/support/turbo_rspec.rb
TurboRspec.configure do |config|
  config.auto_include = false  # disable automatic inclusion
end
```

## Matchers

### `have_turbo_stream`

Assert that a response body contains a `<turbo-stream>` element.

```ruby
# Basic — any turbo stream present
expect(response).to have_turbo_stream

# With action
expect(response).to have_turbo_stream.with_action(:append)
expect(response).to have_turbo_stream.with_action(:replace)
expect(response).to have_turbo_stream.with_action(:remove)

# With target (single DOM id)
expect(response).to have_turbo_stream.targeting("messages")

# With targets (CSS selector)
expect(response).to have_turbo_stream.targeting_all(".message-item")

# With content
expect(response).to have_turbo_stream.with_content("Hello, world!")

# With partial
expect(response).to have_turbo_stream.rendering("messages/_message")

# Chained — all constraints must match the same stream
expect(response).to have_turbo_stream
  .with_action(:append)
  .targeting("messages")
  .with_content("Hello")

# Negation
expect(response).not_to have_turbo_stream.with_action(:replace)
```

#### Actions

Turbo supports the following stream actions: `append`, `prepend`, `replace`, `update`, `remove`, `before`, `after`, `refresh`.

### `have_turbo_streams`

Assert that a response contains **all** of the specified streams in one expectation.

```ruby
expect(response).to have_turbo_streams(
  have_turbo_stream.with_action(:append).targeting("messages"),
  have_turbo_stream.with_action(:replace).targeting("header")
)
```

When a stream is missing the failure message lists each unmatched matcher so you can see at a glance which ones failed.

### `assert_no_turbo_stream`

Alias of `have_turbo_stream` for teams that mix RSpec and minitest terminology.

```ruby
expect(response).not_to assert_no_turbo_stream
```

### `have_turbo_frame`

Assert that a response body contains a `<turbo-frame>` element.

```ruby
# Basic — any turbo frame present
expect(response).to have_turbo_frame

# With id
expect(response).to have_turbo_frame.with_id("messages")

# With content
expect(response).to have_turbo_frame.with_id("messages").with_content("Hello")

# With partial
expect(response).to have_turbo_frame.with_id("post").rendering("posts/_post")

# Negation
expect(response).not_to have_turbo_frame.with_id("notifications")
```

### `have_broadcasted_turbo_stream_to`

Assert that a block broadcasts a `<turbo-stream>` over ActionCable. Requires ActionCable's test adapter.

```ruby
# Basic — any broadcast to the stream
expect { MyJob.perform_now }.to have_broadcasted_turbo_stream_to("notifications")

# With constraints (same chain as have_turbo_stream)
expect { MyJob.perform_now }.to have_broadcasted_turbo_stream_to("notifications")
  .with_action(:append)
  .targeting("messages")
  .with_content("Hello")

# Count qualifiers
expect { MyJob.perform_now }.to have_broadcasted_turbo_stream_to("notifications").once
expect { MyJob.perform_now }.to have_broadcasted_turbo_stream_to("notifications").exactly(3).times
expect { MyJob.perform_now }.to have_broadcasted_turbo_stream_to("notifications").at_least(2).times

# Alias
expect { MyJob.perform_now }.to broadcast_turbo_stream_to("notifications")

# Negation
expect { MyJob.perform_now }.not_to have_broadcasted_turbo_stream_to("notifications")
```

### `have_turbo_frame` (system/feature specs)

Assert that a `<turbo-frame>` element is present on the page (Capybara).

```ruby
# Basic
expect(page).to have_turbo_frame("messages")

# With content
expect(page).to have_turbo_frame("messages").with_content("Hello")

# Loaded (frame finished loading)
expect(page).to have_turbo_frame("messages").loaded

# Negation
expect(page).not_to have_turbo_frame("notifications")
```

### `within_turbo_frame`

Scope Capybara assertions to a specific frame's DOM.

```ruby
within_turbo_frame("messages") do
  expect(page).to have_content("Hello")
  click_button "Reply"
end
```

### `have_turbo_stream_tag`

Assert that a `<turbo-stream-source>` subscription element is on the page.

```ruby
# Any stream source
expect(page).to have_turbo_stream_tag

# With signed stream name
expect(page).to have_turbo_stream_tag("signed_stream_name")

# Negation
expect(page).not_to have_turbo_stream_tag
```

## Test helpers

`TurboRspec::Helpers` provides factory methods for building Turbo HTML inline in tests. Auto-included in `type: :request` and `type: :controller` example groups.

```ruby
# Build a <turbo-stream> element
turbo_stream_html(action: :append, target: "messages", content: "Hello")
turbo_stream_html(action: :remove, targets: ".item")

# Build a <turbo-frame> element
turbo_frame_html(id: "messages", content: "Hello")
```

## Shared examples

```ruby
RSpec.describe "Messages", type: :request do
  describe "POST /messages" do
    before { post messages_path, params: { body: "Hello" }, as: :turbo_stream }

    # Assert any turbo stream is present
    it_behaves_like "a turbo stream response"

    # Assert a specific stream
    it_behaves_like "a turbo stream response", action: :append, target: "messages", content: "Hello"

    # Assert a turbo frame
    it_behaves_like "a turbo frame response", id: "messages"
  end
end
```

## Example: request spec

```ruby
RSpec.describe "Messages", type: :request do
  describe "POST /messages" do
    it "appends the new message to the list" do
      post messages_path, params: { message: { body: "Hello" } },
                          headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_turbo_stream
        .with_action(:append)
        .targeting("messages")
        .with_content("Hello")
    end
  end

  describe "DELETE /messages/:id" do
    it "removes the message row" do
      message = create(:message)
      delete message_path(message),
             headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_turbo_stream
        .with_action(:remove)
        .targeting("message_#{message.id}")
    end
  end
end
```

## Example: system spec

```ruby
RSpec.describe "Messages", type: :system do
  it "appends a new message via Turbo Frame" do
    visit messages_path
    fill_in "Body", with: "Hello"
    click_button "Send"

    expect(page).to have_turbo_frame("messages").with_content("Hello")
  end

  it "shows the subscription stream tag" do
    visit messages_path
    expect(page).to have_turbo_stream_tag
  end
end
```

## Minitest support

`TurboRspec::Assertions` is an opt-in companion module with no RSpec dependency. Include it in any Minitest test class:

```ruby
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include TurboRspec::Assertions
end
```

### Available assertions

```ruby
# Stream assertions
assert_turbo_stream(response, action: :append, target: "messages")
assert_turbo_stream(response, action: :append, target: "messages", content: "Hello")
assert_turbo_stream(response, targets: ".items")
assert_turbo_stream(response, partial: "messages/_message")
refute_turbo_stream(response, action: :replace)

# Frame assertions
assert_turbo_frame(response, id: "messages")
assert_turbo_frame(response, id: "messages", content: "Hello")
refute_turbo_frame(response, id: "notifications")

# Custom failure message
assert_turbo_stream(response, action: :append, message: "expected append stream")
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/eclectic-coding/turbo_rspec).

## License

The gem is available as open source under the [MIT License](https://opensource.org/licenses/MIT).