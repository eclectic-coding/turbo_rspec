# Cookbook: Common Turbo Testing Patterns

## Request specs

### Asserting a single stream

```ruby
RSpec.describe "Messages", type: :request do
  it "appends the new message" do
    post messages_path, params: { message: { body: "Hello" } },
                        headers: { "Accept" => "text/vnd.turbo-stream.html" }

    expect(response).to have_turbo_stream
      .with_action(:append)
      .targeting("messages")
      .with_content("Hello")
  end
end
```

### Asserting multiple streams in one expectation

```ruby
it "updates the list and clears the form" do
  post messages_path, params: { message: { body: "Hello" } }, as: :turbo_stream

  expect(response).to have_turbo_streams(
    have_turbo_stream.with_action(:append).targeting("messages"),
    have_turbo_stream.with_action(:replace).targeting("message_form")
  )
end
```

### Using shared examples

```ruby
RSpec.describe "Messages", type: :request do
  describe "POST /messages" do
    before { post messages_path, params: { body: "Hello" }, as: :turbo_stream }

    it_behaves_like "a turbo stream response", action: :append, target: "messages"
  end
end
```

### Asserting a remove stream

```ruby
it "removes the deleted message" do
  delete message_path(message), as: :turbo_stream

  expect(response).to have_turbo_stream
    .with_action(:remove)
    .targeting("message_#{message.id}")
end
```

### Asserting a Turbo Frame response

```ruby
it "renders the edit form in the frame" do
  get edit_message_path(message)

  expect(response).to have_turbo_frame.with_id("message_#{message.id}")
end
```

## Lazy-loaded Turbo Frames

```ruby
it "lazy-loads the message list frame" do
  get messages_path

  # Assert the frame tag is rendered in the page
  expect(response.body).to include('turbo-frame id="messages"')
end

it "responds to the frame src request" do
  get messages_path, headers: { "Turbo-Frame" => "messages" }

  expect(response).to have_turbo_frame.with_id("messages")
end
```

## Broadcast matchers in job specs

### Basic broadcast assertion

```ruby
RSpec.describe NotifyUsersJob, type: :job do
  it "broadcasts a stream to the user channel" do
    expect { described_class.perform_now(user) }
      .to have_broadcasted_turbo_stream_to("user_#{user.id}")
      .with_action(:append)
      .targeting("notifications")
  end
end
```

### Count qualifiers

```ruby
it "broadcasts exactly once per recipient" do
  expect { described_class.perform_now(users) }
    .to have_broadcasted_turbo_stream_to("notifications")
    .exactly(users.count).times
end
```

### Broadcast to a model (requires turbo-rails)

```ruby
it "broadcasts to the conversation channel" do
  expect { described_class.perform_now }
    .to have_broadcasted_turbo_stream_to(conversation)
    .with_action(:append)
end
```

## Multi-stream responses

A single Turbo Stream response can contain multiple `<turbo-stream>` tags. All matchers handle this correctly — `have_turbo_stream` checks if *any* stream matches, while `have_turbo_streams` requires *all* listed streams to be present.

```ruby
it "broadcasts multiple updates" do
  post bulk_update_path, as: :turbo_stream

  # passes if any one stream is :append
  expect(response).to have_turbo_stream.with_action(:append)

  # passes only if both streams are present
  expect(response).to have_turbo_streams(
    have_turbo_stream.with_action(:append).targeting("list"),
    have_turbo_stream.with_action(:replace).targeting("count")
  )
end
```

## Using factory helpers

```ruby
RSpec.describe "Messages", type: :request do
  # Build test HTML without hand-rolling strings
  let(:stream_body) { turbo_stream_html(action: :append, target: "messages", content: "Hello") }

  it "matches the expected stream" do
    expect(stream_body).to have_turbo_stream.with_action(:append).with_content("Hello")
  end
end
```

## Minitest integration

```ruby
class MessagesControllerTest < ActionDispatch::IntegrationTest
  include TurboRspec::Assertions

  test "appends the new message" do
    post messages_url, params: { message: { body: "Hello" } }, as: :turbo_stream

    assert_turbo_stream(response, action: :append, target: "messages", content: "Hello")
  end

  test "does not render a replace stream" do
    post messages_url, params: { message: { body: "Hello" } }, as: :turbo_stream

    refute_turbo_stream(response, action: :replace)
  end
end
```

## Controller specs

Matchers and helpers are also available in `type: :controller` specs:

```ruby
RSpec.describe MessagesController, type: :controller do
  it "responds with a turbo stream" do
    post :create, params: { message: { body: "Hello" } },
                  format: :turbo_stream

    expect(response).to have_turbo_stream.with_action(:append).targeting("messages")
  end
end
```