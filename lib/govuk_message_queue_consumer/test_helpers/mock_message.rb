module GovukMessageQueueConsumer
  class MockMessage
    attr_reader :acked, :retried, :discarded
    attr_accessor :payload, :delivery_info, :headers

    alias :acked? :acked
    alias :discarded? :discarded
    alias :retried? :retried

    def initialize(payload = {})
      @payload = payload
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
