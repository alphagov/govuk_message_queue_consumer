require_relative '../spec_helper'
require 'govuk_message_queue_consumer/test_helpers'

describe "The usage of the shared example" do
  class WellDevelopedMessageQueueConsumer
    def process(_message)
    end
  end

  describe WellDevelopedMessageQueueConsumer do
    it_behaves_like "a message queue processor"
  end
end
