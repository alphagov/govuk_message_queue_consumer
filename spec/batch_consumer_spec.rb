require_relative 'spec_helper'

describe BatchConsumer do
  let(:processor) { double(:processor, process: true) }
  let(:bunny_mock) { BunnyMock.new }

  def with_consumer
    consumer = described_class.new(
      queue_name: "test",
      processor: processor,
      rabbitmq_connection: bunny_mock,
      batch_size: 3,
      batch_timeout: 0.1
    )
    consumer_thread = Thread.new { consumer.run }

    yield

    # wait for last of thread processing to finish
    # this is required as otherwise the last action
    # can be missed as the stop happens too fast
    sleep 0.05

    consumer.stop
    Timeout.timeout(2) { consumer_thread.join }
  end

  before do
    @channel = bunny_mock.start.channel
    @queue = @channel.queue("test")
  end

  describe "#run" do
    it 'will process a single message off the queue' do
      expect(processor).to receive(:process).with([instance_of(Message)])
      with_consumer do
        @queue.publish(json: 'message')
      end
    end

    it 'will process batches of messages off the queue' do
      expect(processor).to receive(:process).with([instance_of(Message), instance_of(Message), instance_of(Message)])
      expect(processor).to receive(:process).with([instance_of(Message), instance_of(Message), instance_of(Message)])
      expect(processor).to receive(:process).with([instance_of(Message)])
      with_consumer do
        @queue.publish(json: 'message')
        @queue.publish(json: 'message')
        @queue.publish(json: 'message')
        @queue.publish(json: 'message')
        @queue.publish(json: 'message')
        @queue.publish(json: 'message')
        @queue.publish(json: 'message')
      end
    end

    it 'will split messages into batches' do
      expect(processor).to receive(:process).with([instance_of(Message), instance_of(Message), instance_of(Message)])
      with_consumer do
        @queue.publish(json: 'message')
        @queue.publish(json: 'message')
        @queue.publish(json: 'message')
      end
    end

    it 'will process messages that arrive inside the timeout even if the batch limit is not reached' do
      expect(processor).to receive(:process).with([instance_of(Message)]).twice
      with_consumer do
        @queue.publish(json: 'message')
        sleep 0.4
        @queue.publish(json: 'message')
      end
    end
  end
end
