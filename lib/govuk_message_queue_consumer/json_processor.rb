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
      Airbrake.notify_or_ignore(e) if defined?(Airbrake)
      message.discard
    end
  end
end
