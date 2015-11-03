module GovukMessageQueueConsumer
  class TestConsumer < Consumer
    def publish_message(payload, options)
      exchange.publish(payload, options)
    end

    # call after integration tests finish
    def delete_queue
      queue.delete
    end
  end
end
