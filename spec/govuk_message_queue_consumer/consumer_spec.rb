require "spec_helper"
require "support/queue_helpers"

describe GovukMessageQueueConsumer::Consumer do
  include QueueHelpers

  let(:logger) { instance_double(Logger) }
  let(:client_processor) { instance_double(Client::Processor) }

  describe "#run" do
    let(:stubs) { create_bunny_stubs }
    let(:channel) { stubs.channel }
    let(:queue) { stubs.queue }

    it "doesn't create the queue" do
      expect(channel).to receive(:queue).with("some-queue", { no_declare: true })

      described_class.new(queue_name: "some-queue", processor: client_processor, rabbitmq_connection: stubs.connection, logger:).run
    end

    it "doesn't bind the queue" do
      expect(queue).not_to receive(:bind)

      described_class.new(queue_name: "some-queue", processor: client_processor, rabbitmq_connection: stubs.connection, logger:).run
    end

    it "calls the heartbeat processor when subscribing to messages" do
      expect(queue).to receive(:subscribe).and_yield(:delivery_info_object, :headers, "payload")
      heartbeat_processor_stub = instance_double(GovukMessageQueueConsumer::HeartbeatProcessor)
      allow(GovukMessageQueueConsumer::HeartbeatProcessor).to receive(:new).and_return(heartbeat_processor_stub)

      expect(heartbeat_processor_stub).to receive(:process).with(kind_of(GovukMessageQueueConsumer::Message))

      described_class.new(queue_name: "some-queue", processor: client_processor, rabbitmq_connection: stubs.connection, logger:).run
    end

    context "when a SignalException is raised" do
      before do
        allow(queue).to receive(:subscribe).and_raise(error)
      end

      context "and the signal is a SIGTERM" do
        let(:error) { SignalException.new("SIGTERM") }

        it "gracefully exits" do
          expect { described_class.new(queue_name: "some-queue", processor: client_processor, rabbitmq_connection: stubs.connection, logger:).run }.to raise_error(SystemExit)
        end
      end

      context "and the signal is an unexpected one" do
        let(:error) { SignalException.new("SIGWINCH") }

        before do
          stub_const("GovukError", double(notify: nil)) # rubocop:disable RSpec/VerifiedDoubles
        end

        it "gracefully exits after notifying GovukError" do
          expect(GovukError).to receive(:notify).with(error)
          expect { described_class.new(queue_name: "some-queue", processor: client_processor, rabbitmq_connection: stubs.connection, logger:).run }.to raise_error(SystemExit)
        end
      end
    end
  end
end
