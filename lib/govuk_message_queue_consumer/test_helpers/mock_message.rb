module GovukMessageQueueConsumer
  class MockMessage < Message
    attr_reader :acked, :retried, :discarded, :payload, :header, :delivery_info

    alias_method :acked?, :acked
    alias_method :discarded?, :discarded
    alias_method :retried?, :retried

    def initialize(payload = {}, headers = {}, delivery_info = {})
      @payload = payload
      @headers = OpenStruct.new(headers)
      @delivery_info = OpenStruct.new(delivery_info)
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
