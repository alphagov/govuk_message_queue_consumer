require 'bunny'

module GovukMessageQueueConsumer
  class Consumer
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
      @channel.prefetch(1) # only one unacked message at a time
      queue = @channel.queue(@queue_name, :durable => true)
      @bindings.each do |exchange_name, routing_key|
        exchange = @channel.topic(exchange_name, :passive => true)
        queue.bind(exchange, :routing_key => routing_key)
      end
      queue
    end
  end
end
