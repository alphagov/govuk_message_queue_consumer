require_relative 'spec_helper'

describe Consumer do
  let(:message_values) { [:delivery_info1, :headers1, "message1_payload"] }
  let(:queue) { instance_double('Bunny::Queue', bind: nil, subscribe: message_values) }
  let(:channel) { instance_double('Bunny::Channel', queue: queue, prefetch: nil, topic: nil) }
  let(:rabbitmq_connecton) { instance_double("Bunny::Session", start: nil, create_channel: channel) }
  let(:client_processor) { instance_double('Client::Processor') }

  before do
    stub_environment_variables!
    allow(Bunny).to receive(:new).and_return(rabbitmq_connecton)
  end

  describe "running the consumer" do
    it "binds the queue to the all-routing key" do
      class Processor
      end

      expect(queue).to receive(:bind).with(nil, { routing_key: "#" })

      Consumer.new(queue_name: "some-queue", exchange_name: "my-exchange", processor: Processor.new).run
    end

    it "binds the queue to a custom routing key" do
      class Processor
        def routing_key
          "*.major"
        end
      end

      expect(queue).to receive(:bind).with(nil, { routing_key: "*.major" })

      Consumer.new(queue_name: "some-queue", exchange_name: "my-exchange", processor: Processor.new).run
    end

    it "calls the heartbeat processor when subscribing to messages" do
      expect(queue).to receive(:subscribe).and_yield(*message_values)
      expect(Message).to receive(:new).with(*message_values)
      expect_any_instance_of(HeartbeatProcessor).to receive(:process)

      Consumer.new(queue_name: "some-queue", exchange_name: "my-exchange", processor: client_processor).run
    end
  end
end
