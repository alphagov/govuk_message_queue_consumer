require_relative 'spec_helper'

describe HeartbeatProcessor do
  let(:heartbeat_headers) { instance_double("Heartbeat Headers", :content_type => "application/x-heartbeat") }
  let(:heartbeat_message) { instance_double("Heartbeat Message", :headers => heartbeat_headers, :ack => nil) }
  let(:standard_headers) { instance_double("Standard Headers", :content_type => nil) }
  let(:standard_message) { instance_double("Standard Message", :headers => standard_headers, :ack => nil) }

  let(:next_processor) { instance_double("Client::Processor") }

  subject {
    HeartbeatProcessor.new(next_processor)
  }

  context "for a heartbeat message" do
    it "doesn't call the next processor" do
      expect(next_processor).not_to receive(:process)

      subject.process(heartbeat_message)
    end

    it "acks the message" do
      expect(heartbeat_message).to receive(:ack)

      subject.process(heartbeat_message)
    end
  end

  context "for a content message" do
    it "calls the next processor" do
      expect(next_processor).to receive(:process).with(standard_message)

      subject.process(standard_message)
    end

    it "doesn't ack the message" do
      expect(standard_message).not_to receive(:ack)
      expect(next_processor).to receive(:process)

      subject.process(standard_message)
    end
  end
end
