if defined?(RSpec)
  RSpec.shared_examples "a message queue processor" do
    it "implements #process" do
      expect(subject).to respond_to(:process)
    end

    it "accepts 1 argument for #process" do
      expect(subject.method(:process).arity).to eq(1)
    end

    it "sets a ROUTING_KEY" do
      expect { subject.class.const_get("ROUTING_KEY") }.not_to raise_error
    end

    it "returns a useful ROUTING_KEY" do
      expect(subject.class::ROUTING_KEY).not_to eq("")
      expect(subject.class::ROUTING_KEY).not_to be_nil
    end
  end
end
