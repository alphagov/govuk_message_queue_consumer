require 'json'

module MessageQueueConsumer
  # Client code will receive an instance of this
  class Message
    def initialize(delivery_info, headers, payload)
      @delivery_info = delivery_info
      @headers = headers
      @body = payload
    end

    attr_reader :delivery_info, :headers, :body

    def body_data
      @body_data ||= JSON.parse(@body)
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
