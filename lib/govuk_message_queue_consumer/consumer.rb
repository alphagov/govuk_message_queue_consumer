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

    def initialize(queue_name:, exchange_name:, processor:)
      @queue_name = queue_name
      @exchange_name = exchange_name
      @processor = processor
    end

    def run
      queue.subscribe(block: true, manual_ack: true) do |delivery_info, headers, payload|
        begin
          message = Message.new(delivery_info, headers, payload)
          processor_chain.process(message)
        rescue Exception => e
          $stderr.puts "rabbitmq_consumer: aborting due to unhandled exception in processor #{e.class}: #{e.message}"
          exit(1) # ensure rabbitmq requeues outstanding messages
        end
      end
    end

  private

    def processor_chain
      @processor_chain ||= HeartbeatProcessor.new(JSONProcessor.new(@processor))
    end

    def queue
      @queue ||= begin
        channel.prefetch(NUMBER_OF_MESSAGES_TO_PREFETCH)
        queue = channel.queue(@queue_name, durable: true)
        queue.bind(exchange, routing_key: routing_key)
        queue
      end
    end

    def exchange
      @exchange ||= channel.topic(@exchange_name, passive: true)
    end

    def channel
      @channel ||= connection.create_channel
    end

    def connection
      @connection ||= begin
        new_connection = Bunny.new(RabbitMQConfig.new.from_environment)
        new_connection.start
        new_connection
      end
    end

    def routing_key
      @processor.routing_key
    end
  end
end
