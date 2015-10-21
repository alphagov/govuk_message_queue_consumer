require_relative 'spec_helper'

describe Consumer do

  let(:queue) { instance_double('Bunny::Queue', bind: nil, subscribe: message_values) }
  let(:channel) { instance_double('Bunny::Channel', queue: queue, prefetch: nil, topic: nil) }
  let(:rabbitmq_connecton) { instance_double("Bunny::Session", start: nil, create_channel: channel) }
  let(:client_processor) { instance_double('Client::Processor') }

  before do
    allow(Bunny).to receive(:new).and_return(rabbitmq_connecton)
  end

  describe "constructing an instance" do
    let(:rabbitmq_connecton) { instance_double("Bunny::Session", start: nil, create_channel: channel) }
    let(:client_processor) { instance_double('Client::Processor') }

    it "passes the client processor to the Heartbeat Processor" do
      expect(HeartbeatProcessor).to receive(:new).with(client_processor)

      Consumer.new(rabbitmq_config, client_processor)
    end

    it "connects to rabbitmq" do
      expected_options = rabbitmq_config.fetch(:connection)
      expect(Bunny).to receive(:new).with(expected_options).and_return(rabbitmq_connecton)
      expect(rabbitmq_connecton).to receive(:start)

      Consumer.new(rabbitmq_config, client_processor)
    end
  end

  describe "running the consumer" do
    it "binds the queue" do
      expect(queue).to receive(:bind)

      Consumer.new(rabbitmq_config, client_processor).run
    end

    it "calls the heartbeat processor when subscribing to messages" do
      expect(queue).to receive(:subscribe).and_yield(*message_values)
      expect(Message).to receive(:new).with(*message_values)
      expect_any_instance_of(HeartbeatProcessor).to receive(:process)

      Consumer.new(rabbitmq_config, client_processor).run
    end
  end
end
