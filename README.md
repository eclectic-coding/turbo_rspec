# TurboRspec

RSpec matchers for [Turbo](https://github.com/hotwired/turbo-rails) — assert Turbo Stream responses, Turbo Frame content, and ActionCable broadcasts without hand-rolling helpers in every project.

## Installation

Add to your application's `Gemfile`:

```ruby
group :test do
  gem "turbo_rspec"
end
```

## Setup

### Rails + turbo-rails (automatic)

No setup needed. When `turbo-rails` is in your bundle, `TurboRspec::Matchers` is automatically included in all `type: :request` example groups.

### Manual include

For non-Rails projects or custom contexts, include the matchers explicitly:

```ruby
# spec/spec_helper.rb
RSpec.configure do |config|
  config.include TurboRspec::Matchers
end
```

### Configuration

```ruby
# spec/support/turbo_rspec.rb
TurboRspec.configure do |config|
  config.auto_include = false  # disable automatic inclusion into request specs
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

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/eclectic-coding/turbo_rspec).

## License

The gem is available as open source under the [MIT License](https://opensource.org/licenses/MIT).