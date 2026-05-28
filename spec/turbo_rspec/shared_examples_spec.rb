# frozen_string_literal: true

RSpec.describe "shared examples" do
  include TurboRspec::Matchers
  include TurboRspec::Helpers

  describe '"a turbo stream response"' do
    let(:response) { double(body: turbo_stream_html(action: :append, target: "list", content: "Hello")) }

    it_behaves_like "a turbo stream response"
    it_behaves_like "a turbo stream response", action: :append
    it_behaves_like "a turbo stream response", target: "list"
    it_behaves_like "a turbo stream response", content: "Hello"
  end

  describe '"a turbo stream response" with targets' do
    let(:response) { double(body: turbo_stream_html(action: :remove, targets: ".item")) }

    it_behaves_like "a turbo stream response", targets: ".item"
  end

  describe '"a turbo stream response" with partial' do
    let(:response) { double(body: '<turbo-stream action="append" target="list"><template><!-- _item.html.erb --></template></turbo-stream>') }

    it_behaves_like "a turbo stream response", partial: "_item.html.erb"
  end

  describe '"a turbo frame response"' do
    let(:response) { double(body: turbo_frame_html(id: "messages", content: "Hello")) }

    it_behaves_like "a turbo frame response"
    it_behaves_like "a turbo frame response", id: "messages"
    it_behaves_like "a turbo frame response", content: "Hello"
  end

  describe '"a turbo frame response" with partial' do
    let(:response) { double(body: '<turbo-frame id="post"><!-- _post.html.erb --></turbo-frame>') }

    it_behaves_like "a turbo frame response", partial: "_post.html.erb"
  end
end
