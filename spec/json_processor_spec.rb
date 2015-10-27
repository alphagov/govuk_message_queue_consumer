require_relative 'spec_helper'

describe JSONProcessor do
  describe "#process" do
    it "parses the payload string" do
      next_processor = double("next_processor", process: "ha")
      message = MockMessage.new({delivery:'info'}, '{"some":"json"}', headers: { content_type: "application/json" })

      JSONProcessor.new(next_processor).process(message)

      expect(message.payload).to eql({ "some" => "json" })
      expect(next_processor).to have_received(:process)
    end

    it "discards messages with JSON errors" do
      message = MockMessage.new({delivery:'info'}, '{"some" "json"}', headers: { content_type: "application/json" })

      JSONProcessor.new(double).process(message)

      expect(message).to be_discarded
    end

    it "doesn't parse non-JSON message" do
      next_processor = double("next_processor", process: "ha")
      message = MockMessage.new({delivery:'info'}, '<SomeXML></SomeXML>', headers: { content_type: "application/xml" })

      JSONProcessor.new(next_processor).process(message)

      expect(message.payload).to eql('<SomeXML></SomeXML>')
      expect(next_processor).to have_received(:process)
    end
  end
end
