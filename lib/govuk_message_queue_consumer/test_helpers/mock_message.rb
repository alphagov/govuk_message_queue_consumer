module GovukMessageQueueConsumer
  class MockMessage
    attr_reader :acked, :retried, :discarded, :body_data, :delivery_info,
                :headers, :body

    alias :acked? :acked
    alias :discarded? :discarded
    alias :retried? :retried

    def initialize(body_data = {})
      @body_data = body_data
    end

    def ack
      @acked = true
    end

    def retry
      @retried = true
    end

    def discard
      @discarded = true
    end
  end
end
