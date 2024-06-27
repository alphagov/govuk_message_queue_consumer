require "spec_helper"

describe GovukMessageQueueConsumer::Message do
  let(:mock_channel) { instance_double(Channel) }
  let(:delivery_info) { instance_double(DeliveryInfo, channel: mock_channel, delivery_tag: "a_tag") }
  let(:headers) { instance_double(Headers) }
  let(:message) { described_class.new({ "a" => "payload" }, headers, delivery_info) }

  it "ack sends an ack to the channel" do
    expect(mock_channel).to receive(:ack).with("a_tag")

    message.ack

    expect(message.status).to be(:acked)
  end

  it "retry sends a reject to the channel with requeue set" do
    expect(mock_channel).to receive(:reject).with("a_tag", true)

    message.retry

    expect(message.status).to be(:retried)
  end

  it "reject sends a reject to the channel without requeue set" do
    expect(mock_channel).to receive(:reject).with("a_tag", false)

    message.discard

    expect(message.status).to be(:discarded)
  end
end
