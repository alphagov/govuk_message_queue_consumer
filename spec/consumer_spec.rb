require_relative 'spec_helper'

describe Consumer do

  let(:config) {{
      "connection" => {
        "hosts" => ["rabbitmq1.example.com", "rabbitmq2.example.com"],
        "port" => 5672,
        "vhost" => "/",
        "user" => "a_user",
        "pass" => "super secret",
        "recover_from_connection_close" => true,
      },
      "queue" => "content_register",
      "exchange" => "published_documents",
    }}
  let(:queue) { instance_double('Bunny::Queue', bind: nil, subscribe: nil) }
  let(:channel) { instance_double('Bunny::Channel', queue: queue, prefetch: nil, topic: nil) }
  let(:rabbitmq_connecton) { instance_double("Bunny::Session", start: nil, create_channel: channel) }
  let(:client_processor) { instance_double('Client::Processor') }

  before do
    allow(Bunny).to receive(:new).and_return(rabbitmq_connecton)
  end

  describe "constructing an instance" do
    it "passes the client processor to the Heartbeat Processor" do
      expect(HeartbeatProcessor).to receive(:new).with(client_processor)

      Consumer.new(config, client_processor)
    end

    it "connects to rabbitmq" do
      expected_options = config['connection'].symbolize_keys # Bunny requires the keys to be symbols
      expect(Bunny).to receive(:new).with(expected_options).and_return(rabbitmq_connecton)
      expect(rabbitmq_connecton).to receive(:start)

      Consumer.new(config, client_processor)
    end
  end

  describe "running" do
    it "sets the prefetch to 1" do
      expect(channel).to receive(:prefetch).with(1)

      Consumer.new(config, client_processor).run
    end

    it "subscribes to a queue" do
      expect(queue).to receive(:bind)
      expect(queue).to receive(:subscribe)

      Consumer.new(config, client_processor).run
    end

    it "calls the heartbeat processor" do
      msg_vals = [:delivery_info1, :headers1, "message1_body"]
      expect(queue).to receive(:subscribe).and_yield(*msg_vals)
      expect(Message).to receive(:new).with(*msg_vals)
      expect_any_instance_of(HeartbeatProcessor).to receive(:process)

      Consumer.new(config, client_processor).run
    end
  end
end
