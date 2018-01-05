module GovukMessageQueueConsumer
  class JSONProcessor
    JSON_FORMAT = "application/json".freeze

    def process(message)
      if message.headers.content_type == JSON_FORMAT
        message.payload = JSON.parse(message.payload)
      end

      true
    rescue JSON::ParserError => e
      GovukError.notify(e) if defined?(GovukError)
      message.discard
      false
    end
  end
end
