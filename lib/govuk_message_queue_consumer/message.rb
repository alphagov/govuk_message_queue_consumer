require 'json'

module GovukMessageQueueConsumer
  # Client code will receive an instance of this
  class Message
    attr_accessor :delivery_info, :headers, :payload

    def initialize(payload, headers, delivery_info)
      @headers = headers
      @payload = payload
      @delivery_info = delivery_info
    end

    def ack
      @delivery_info.channel.ack(@delivery_info.delivery_tag)
    end

    def retry
      @delivery_info.channel.reject(@delivery_info.delivery_tag, true)
    end

    def discard
      @delivery_info.channel.reject(@delivery_info.delivery_tag, false)
    end
  end
end
