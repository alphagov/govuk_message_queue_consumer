module GovukMessageQueueConsumer
  class BatchConsumer < Consumer
    HANDLE_BATCHES = true
    DEFAULT_BATCH_SIZE = 100
    DEFAULT_BATCH_TIMEOUT = 5
    # we want to increase the prefetch size here to the batch size
    # so that we don't need to do multiple fetches for a batch.
    NUMBER_OF_MESSAGES_TO_PREFETCH = DEFAULT_BATCH_SIZE

    def initialize(options={})
      opts = options.dup
      @batch_size = opts.delete(:batch_size) || DEFAULT_BATCH_SIZE
      @batch_timeout = opts.delete(:batch_timeout) || DEFAULT_BATCH_TIMEOUT
      super(opts)
    end

    def run
      @rabbitmq_connection.start
      @running = true
      while @running do
        process_batch
      end
    end

    # used for testing to stop processing in a different thread
    def stop
      @running = false
    end

  private

    def process_batch
      messages = []
      with_timeout do
        while messages.count < @batch_size do
          delivery_info, headers, payload = queue.pop(manual_ack: true)
          messages << Message.new(payload, headers, delivery_info) if payload
        end
      end

      if messages.any?
        @statsd_client.count("#{@queue_name}.started", messages.count)
        @statsd_client.increment("#{@queue_name}.batch_started")
        message_consumer.process(messages)

        status_counts = messages.map(&:status).each_with_object(Hash.new(0)) { |s, h| h[s] += 1 }
        status_counts.each do |status, count|
          @statsd_client.count("#{@queue_name}.#{status}", count)
        end
        @statsd_client.increment("#{@queue_name}.batch_complete")
      end
    rescue Exception => e
      @statsd_client.increment("#{@queue_name}.uncaught_exception")
      GovukError.notify(e) if defined?(GovukError)
      @logger.error "Uncaught exception in processor: \n\n #{e.class}: #{e.message}\n\n#{e.backtrace.join("\n")}"

      exit(1) # Ensure rabbitmq requeues outstanding messages
    end

    def with_timeout
      begin
        Timeout.timeout(@batch_timeout) do
          yield
        end
      rescue Timeout::Error
      end
    end
  end
end
