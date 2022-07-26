require "spec_helper"

describe GovukMessageQueueConsumer::HeartbeatProcessor do
  let(:heartbeat_headers) { instance_double("Heartbeat Headers", content_type: "application/x-heartbeat") }
  let(:heartbeat_message) { instance_double("Heartbeat Message", headers: heartbeat_headers, ack: nil) }
  let(:standard_headers) { instance_double("Standard Headers", content_type: nil) }
  let(:standard_message) { instance_double("Standard Message", headers: standard_headers, ack: nil) }

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
