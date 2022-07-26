require_relative "spec_helper"

describe HeartbeatProcessor do
  subject do
    described_class.new
  end

  let(:heartbeat_headers) { instance_double("Heartbeat Headers", content_type: "application/x-heartbeat") }
  let(:heartbeat_message) { instance_double("Heartbeat Message", headers: heartbeat_headers, ack: nil) }
  let(:standard_headers) { instance_double("Standard Headers", content_type: nil) }
  let(:standard_message) { instance_double("Standard Message", headers: standard_headers, ack: nil) }

  context "for a heartbeat message" do
    it "doesn't call the next processor" do
      expect(subject.process(heartbeat_message)).to be_falsy
    end

    it "acks the message" do
      expect(heartbeat_message).to receive(:ack)

      subject.process(heartbeat_message)
    end
  end

  context "for a content message" do
    it "calls the next processor" do
      expect(subject.process(standard_message)).to be_truthy
    end

    it "doesn't ack the message" do
      expect(standard_message).not_to receive(:ack)

      subject.process(standard_message)
    end
  end
end
