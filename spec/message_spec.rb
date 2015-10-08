require_relative 'spec_helper'

describe Message do
  let(:mock_channel) { instance_double("Channel") }
  let(:delivery_info) { instance_double("DeliveryInfo", :channel => mock_channel, :delivery_tag => "a_tag") }
  let(:headers) { instance_double("Headers") }
  let(:body) { {"foo" => "bar"}.to_json }
  let(:message) { Message.new(delivery_info, headers, body) }

  it "json decodes the body" do
    expect(message.body_data).to eq("foo" => "bar")
  end

  it "ack sends an ack to the channel" do
    expect(mock_channel).to receive(:ack).with("a_tag")
    message.ack
  end

  it "retry sends a reject to the channel with requeue set" do
    expect(mock_channel).to receive(:reject).with("a_tag", true)
    message.retry
  end

  it "reject sends a reject to the channel without requeue set" do
    expect(mock_channel).to receive(:reject).with("a_tag", false)
    message.discard
  end
end
