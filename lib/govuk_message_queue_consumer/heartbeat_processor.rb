module GovukMessageQueueConsumer
  class HeartbeatProcessor
    def initialize(next_processor)
      @next_processor = next_processor
    end

    def process(message)
      if message.is_a?(Array)
        heartbeat_messages, messages_to_process =
          message.partition { |msg| msg.headers.content_type == "application/x-heartbeat" }
        heartbeat_messages.each(&:ack)
        @next_processor.process(messages_to_process) if messages_to_process.any?
      else
        # Ignore heartbeat messages
        if message.headers.content_type == "application/x-heartbeat"
          message.ack
        else
          @next_processor.process(message)
        end
      end
    end
  end
end
