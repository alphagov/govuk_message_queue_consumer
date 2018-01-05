require_relative 'spec_helper'

describe JSONProcessor do
  describe "#process" do
    it "parses the payload string" do
      message = MockMessage.new('{"some":"json"}', { content_type: "application/json" })

      expect(JSONProcessor.new.process(message)).to be_truthy

      expect(message.payload).to eql({ "some" => "json" })
    end

    it "discards messages with JSON errors" do
      message = MockMessage.new('{"some" "json"}', { content_type: "application/json" })

      expect(JSONProcessor.new.process(message)).to be_falsy

      expect(message).to be_discarded
    end

    it "doesn't parse non-JSON message" do
      message = MockMessage.new('<SomeXML></SomeXML>', { content_type: "application/xml" })

      expect(JSONProcessor.new.process(message)).to be_truthy

      expect(message.payload).to eql('<SomeXML></SomeXML>')
    end
  end
end
