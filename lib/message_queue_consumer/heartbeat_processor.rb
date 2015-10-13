module MessageQueueConsumer
  class HeartbeatProcessor
    def initialize(next_processor)
      @next_processor = next_processor
    end

    def process(message)
      # Ignore heartbeat messages
      if message.headers.content_type == "application/x-heartbeat"
        message.ack
      else
        @next_processor.process(message)
      end
    end
  end
end
