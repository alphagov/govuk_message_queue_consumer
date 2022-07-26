require_relative "spec_helper"
require_relative "support/queue_helpers"

describe Consumer do
  include QueueHelpers

  let(:logger) { instance_double("Logger") }
  let(:client_processor) { instance_double("Client::Processor") }

  describe "#run" do
    it "doesn't create the queue" do
      stubs = create_bunny_stubs
      channel = stubs.channel

      expect(channel).to receive(:queue).with("some-queue", { no_declare: true })

      described_class.new(queue_name: "some-queue", processor: client_processor, rabbitmq_connection: stubs.connection, logger: logger).run
    end

    it "doesn't bind the queue" do
      stubs = create_bunny_stubs
      queue = stubs.queue

      expect(queue).not_to receive(:bind)

      described_class.new(queue_name: "some-queue", processor: client_processor, rabbitmq_connection: stubs.connection, logger: logger).run
    end

    it "calls the heartbeat processor when subscribing to messages" do
      stubs = create_bunny_stubs
      queue = stubs.queue

      expect(queue).to receive(:subscribe).and_yield(:delivery_info_object, :headers, "payload")
      heartbeat_processor_stub = instance_double(HeartbeatProcessor)
      allow(HeartbeatProcessor).to receive(:new).and_return(heartbeat_processor_stub)

      expect(heartbeat_processor_stub).to receive(:process).with(kind_of(Message))

      described_class.new(queue_name: "some-queue", processor: client_processor, rabbitmq_connection: stubs.connection, logger: logger).run
    end
  end
end
