module GovukMessageQueueConsumer
  class JSONProcessor
    JSON_FORMAT = "application/json".freeze

    def initialize(next_processor)
      @next_processor = next_processor
    end

    def process(message)
      if message.is_a?(Array)
        valid_messages = message.map { |msg| process_message(msg) }.compact
        @next_processor.process(valid_messages) if valid_messages.any?
      else
        msg = process_message(message)
        @next_processor.process(msg) if msg
      end
    end

  private

    def process_message(message)
      if message.headers.content_type == JSON_FORMAT
        message.payload = JSON.parse(message.payload)
      end

      message
    rescue JSON::ParserError => e
      GovukError.notify(e) if defined?(GovukError)
      message.discard
      nil
    end
  end
end
