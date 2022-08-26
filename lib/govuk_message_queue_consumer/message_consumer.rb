module GovukMessageQueueConsumer
  class MessageConsumer
    def initialize(processors:, handle_batches:)
      @processors = processors
      @handle_batches = handle_batches
    end

    def process(records)
      @processors.inject(Array(records)) do |remaining_records, processor|
        if handles_batches?(processor)
          processor.process(remaining_records)
        else
          remaining_records.select { |record| processor.process(record) }
        end
      end
    end

    def handles_batches?(processor)
      case processor
      when HeartbeatProcessor, JSONProcessor
        false
      else
        @handle_batches
      end
    end
  end
end
