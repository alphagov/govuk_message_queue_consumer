module GovukMessageQueueConsumer
  class JSONProcessor
    def initialize(next_processor)
      @next_processor = next_processor
    end

    def process(message)
      message.payload = JSON.parse(message.payload)
      @next_processor.process(message)
    rescue JSON::ParserError
      message.discard
    end
  end
end
