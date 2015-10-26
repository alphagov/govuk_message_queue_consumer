module GovukMessageQueueConsumer
  class TestConsumer < Consumer
    def publish_message(payload, options)
      exchange.publish(payload, options)
    end
  end
end
