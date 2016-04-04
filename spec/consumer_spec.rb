require_relative 'spec_helper'

describe Consumer do
  let(:queue) { instance_double('Bunny::Queue', bind: nil, subscribe: '') }
  let(:channel) { instance_double('Bunny::Channel', queue: queue, prefetch: nil, topic: nil) }
  let(:rabbitmq_connecton) { instance_double("Bunny::Session", start: nil, create_channel: channel) }
  let(:client_processor) { instance_double('Client::Processor') }

  before do
    stub_environment_variables!
    allow(Bunny).to receive(:new).and_return(rabbitmq_connecton)
  end

  describe "#run" do
    it "binds the queue to the all-routing key" do
      expect(queue).to receive(:bind).with(nil, { routing_key: "#" })

      Consumer.new(queue_name: "some-queue", exchange_name: "my-exchange", processor: client_processor).run
    end

    it "binds the queue to a custom routing key" do
      expect(queue).to receive(:bind).with(nil, { routing_key: "*.major" })

      Consumer.new(queue_name: "some-queue", exchange_name: "my-exchange", processor: client_processor, routing_key: "*.major").run
    end

    it "calls the heartbeat processor when subscribing to messages" do
      expect(queue).to receive(:subscribe).and_yield(:delivery_info_object, :headers, "payload")
      expect_any_instance_of(HeartbeatProcessor).to receive(:process).with(kind_of(Message))

      Consumer.new(queue_name: "some-queue", exchange_name: "my-exchange", processor: client_processor).run
    end
  end
end
