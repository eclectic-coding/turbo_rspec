# Migration Guide: Replacing Hand-Rolled Turbo Helpers

If your test suite has accumulated custom helpers for asserting Turbo Stream responses, this guide shows how to replace them with `turbo_rspec` matchers.

## Common hand-rolled patterns

### Pattern 1: Parsing the response body manually

```ruby
# Before
def assert_turbo_stream_append(target:)
  doc = Nokogiri::HTML(response.body)
  stream = doc.at_css("turbo-stream[action='append'][target='#{target}']")
  assert stream, "Expected append stream targeting #{target}"
end

it "appends the message" do
  post messages_path, params: { body: "Hello" }, as: :turbo_stream
  assert_turbo_stream_append(target: "messages")
end
```

```ruby
# After — RSpec
expect(response).to have_turbo_stream.with_action(:append).targeting("messages")

# After — Minitest
assert_turbo_stream(response, action: :append, target: "messages")
```

### Pattern 2: String matching on the response body

```ruby
# Before
def expect_turbo_stream(action:, target:)
  expect(response.body).to include("action=\"#{action}\"")
  expect(response.body).to include("target=\"#{target}\"")
end
```

```ruby
# After
expect(response).to have_turbo_stream.with_action(:append).targeting("messages")
```

### Pattern 3: Checking multiple streams

```ruby
# Before
def assert_turbo_streams(*expected)
  expected.each do |action:, target:|
    assert response.body.include?("action=\"#{action}\"")
  end
end
```

```ruby
# After
expect(response).to have_turbo_streams(
  have_turbo_stream.with_action(:append).targeting("messages"),
  have_turbo_stream.with_action(:replace).targeting("header")
)
```

### Pattern 4: Custom broadcast helpers in job specs

```ruby
# Before
def expect_broadcast_to(stream, action:, target:)
  messages = ActionCable.server.pubsub.broadcasts(stream)
  assert messages.any? { |m| m.include?(action.to_s) && m.include?(target) }
end
```

```ruby
# After
expect { MyJob.perform_now }.to have_broadcasted_turbo_stream_to("stream")
  .with_action(:append)
  .targeting("messages")
```

## Setup

Remove any custom helpers from `spec/support/` or `test/test_helper.rb` and add to your `Gemfile`:

```ruby
group :test do
  gem "turbo_rspec"
end
```

With `turbo-rails` in your bundle, matchers are automatically included in `type: :request` and `type: :controller` specs. For Minitest, include manually:

```ruby
class ActionDispatch::IntegrationTest
  include TurboRspec::Assertions
end
```