module GovukMessageQueueConsumer
  class MessageConsumer
    def initialize(processors:)
      @processors = processors
    end

    def process(records)
      @processors.inject(Array(records)) do |remaining_records, processor|
        remaining_records.select { |record| processor.process(record) }
      end
    end
  end
end
