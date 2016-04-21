require_relative '../spec_helper'
require 'govuk_message_queue_consumer/test_helpers'

describe GovukMessageQueueConsumer::MockMessage do
  describe '#methods' do
    it "implements the same methods as Message" do
      mock = MockMessage.new
      real = Message.new(double, double, double)

      expect(real.methods - mock.methods).to be_empty
    end
  end

  describe '#ack' do
    it "marks the message as acked" do
      message = MockMessage.new

      message.ack

      expect(message).to be_acked
    end
  end

  describe '#retry' do
    it "marks the message as retried" do
      message = MockMessage.new

      message.retry

      expect(message).to be_retried
    end
  end

  describe '#discard' do
    it "marks the message as discarded" do
      message = MockMessage.new

      message.discard

      expect(message).to be_discarded
    end
  end
end
