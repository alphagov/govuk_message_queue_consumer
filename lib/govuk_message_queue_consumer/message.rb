require 'json'

module GovukMessageQueueConsumer
  # Client code will receive an instance of this
  class Message
    attr_accessor :delivery_info, :headers, :payload, :status

    def initialize(payload, headers, delivery_info)
      @payload = payload
      @headers = headers
      @delivery_info = delivery_info
      @status = :status
    end

    def ack
      @delivery_info.channel.ack(@delivery_info.delivery_tag)
      @status = :acked
    end

    def retry
      @delivery_info.channel.reject(@delivery_info.delivery_tag, true)
      @status = :retried
    end

    def discard
      @delivery_info.channel.reject(@delivery_info.delivery_tag, false)
      @status = :discarded
    end
  end
end
