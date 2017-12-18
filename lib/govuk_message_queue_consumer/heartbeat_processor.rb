module GovukMessageQueueConsumer
  class HeartbeatProcessor
    def process(message)
      # Ignore heartbeat messages
      if message.headers.content_type == "application/x-heartbeat"
        message.ack
        return false
      end

      true
    end
  end
end
