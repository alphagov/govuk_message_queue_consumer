require "spec_helper"

describe GovukMessageQueueConsumer::HeartbeatProcessor do
  let(:heartbeat_headers) { double }
  let(:heartbeat_message) { double }
  let(:standard_headers) { double }
  let(:standard_message) { double }

  before do
    allow(heartbeat_headers).to receive(:content_type).and_return("application/x-heartbeat")
    allow(heartbeat_message).to receive_messages(headers: heartbeat_headers, ack: nil)
    allow(standard_headers).to receive(:content_type).and_return(nil)
    allow(standard_message).to receive_messages(headers: standard_headers, ack: nil)
  end

  context "when receiving heartbeat message" do
    it "doesn't call the next processor" do
      processor = described_class.new
      expect(processor.process(heartbeat_message)).to be_falsy
    end

    it "acks the message" do
      expect(heartbeat_message).to receive(:ack)

      processor = described_class.new
      processor.process(heartbeat_message)
    end
  end

  context "when receiving a content message" do
    it "calls the next processor" do
      processor = described_class.new
      expect(processor.process(standard_message)).to be_truthy
    end

    it "doesn't ack the message" do
      expect(standard_message).not_to receive(:ack)

      processor = described_class.new
      processor.process(standard_message)
    end
  end
end
