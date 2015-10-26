module GovukMessageQueueConsumer
  class JSONProcessor
    def initialize(next_processor)
      @next_processor = next_processor
    end

    def process(message)
      message.payload = JSON.parse(message.payload)
      @next_processor.process(message)
    rescue JSON::ParserError => e
      Airbrake.notify_or_ignore(e) if defined?(Airbrake)
      message.discard
    end
  end
end
