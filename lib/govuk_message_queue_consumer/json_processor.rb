module GovukMessageQueueConsumer
  class JSONProcessor
    JSON_FORMAT = "application/json".freeze

    def initialize(next_processor)
      @next_processor = next_processor
    end

    def process(message)
      if message.headers.content_type == JSON_FORMAT
        message.payload = JSON.parse(message.payload)
      end

      @next_processor.process(message)
    rescue JSON::ParserError => e
      GovukError.notify(e) if defined?(GovukError)
      message.discard
    end
  end
end
