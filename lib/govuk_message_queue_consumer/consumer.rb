require 'bunny'

module GovukMessageQueueConsumer
  class Consumer
    # Only fetch one message at a time on the channel.
    #
    # By default, queues will grab messages eagerly, which reduces latency.
    # However, that also means that if multiple workers are running one worker
    # can starve another of work.  We're not expecting a high throughput on this
    # queue, and a small bit of latency isn't a problem, so we fetch one at a
    # time to share the work evenly.
    NUMBER_OF_MESSAGES_TO_PREFETCH = 1

    def initialize(queue_name:, exchange:, processor:)
      @processor = HeartbeatProcessor.new(processor)
      @queue_name = queue_name
      @bindings = { exchange => "#" }
      @connection = Bunny.new(RabbitMQConfig.new.from_environment)
      @connection.start
    end

    def run
      queue.subscribe(:block => true, :manual_ack => true) do |delivery_info, headers, payload|
        begin
          @processor.process(Message.new(delivery_info, headers, payload))
        rescue Exception => e
          $stderr.puts "rabbitmq_consumer: aborting due to unhandled exception in processor #{e.class}: #{e.message}"
          exit(1) # ensure rabbitmq requeues outstanding messages
        end
      end
    end

    private

    def queue
      @queue ||= setup_queue
    end

    def setup_queue
      @channel = @connection.create_channel
      @channel.prefetch(NUMBER_OF_MESSAGES_TO_PREFETCH)
      queue = @channel.queue(@queue_name, :durable => true)
      @bindings.each do |exchange_name, routing_key|
        exchange = @channel.topic(exchange_name, :passive => true)
        queue.bind(exchange, :routing_key => routing_key)
      end
      queue
    end
  end
end
