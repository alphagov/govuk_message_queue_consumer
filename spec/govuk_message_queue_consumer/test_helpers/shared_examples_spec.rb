require "spec_helper"
require "govuk_message_queue_consumer/test_helpers"

describe "The usage of the shared example" do
  subject do
    klass = Class.new do
      def process(_message); end
    end

    klass.new
  end

  it_behaves_like "a message queue processor"
end
