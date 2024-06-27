require "spec_helper"
require "govuk_message_queue_consumer/test_helpers"

describe GovukMessageQueueConsumer::MockMessage do # rubocop:disable RSpec/SpecFilePathFormat
  describe "#methods" do
    it "implements the same methods as Message" do
      mock = described_class.new
      real = GovukMessageQueueConsumer::Message.new(double, double, double)

      expect(real.methods - mock.methods).to be_empty
    end
  end

  describe "#ack" do
    it "marks the message as acked" do
      message = described_class.new

      message.ack

      expect(message).to be_acked
    end
  end

  describe "#retry" do
    it "marks the message as retried" do
      message = described_class.new

      message.retry

      expect(message).to be_retried
    end
  end

  describe "#discard" do
    it "marks the message as discarded" do
      message = described_class.new

      message.discard

      expect(message).to be_discarded
    end
  end
end
