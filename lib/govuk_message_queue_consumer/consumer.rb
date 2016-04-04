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

    # Create a new consumer
    #
    # @param queue_name [String] Your queue name. This is specific to your application.
    # @param exchange_name [String] Name of the exchange to bind to, for example `published_documents`
    # @param processor [Object] An object that responds to `process`
    # @param routing_key [String] The RabbitMQ routing key to bind the queue to
    def initialize(queue_name:, exchange_name:, processor:, routing_key: '#')
      @queue_name = queue_name
      @exchange_name = exchange_name
      @processor = processor
      @routing_key = routing_key
    end

    def run
      queue.subscribe(block: true, manual_ack: true) do |delivery_info, headers, payload|
        begin
          message = Message.new(payload, headers, delivery_info)
          processor_chain.process(message)
        rescue Exception => e
          Airbrake.notify_or_ignore(e) if defined?(Airbrake)
          $stderr.puts "Uncaught exception in processor: \n\n #{e.class}: #{e.message}\n\n#{e.backtrace.join("\n")}"
          exit(1) # Ensure rabbitmq requeues outstanding messages
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
        queue.bind(exchange, routing_key: @routing_key)
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
  end
end
