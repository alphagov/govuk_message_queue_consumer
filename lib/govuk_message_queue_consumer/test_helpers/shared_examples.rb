if defined?(RSpec)
  RSpec.shared_examples "a message queue processor" do
    it "implements #process" do
      expect(subject).to respond_to(:process)
    end

    it "accepts 1 argument for #process" do
      expect(subject.method(:process).arity).to eq(1)
    end

    it "implements #routing_key" do
      expect(subject).to respond_to(:routing_key)
    end

    it "returns a useful routing_key" do
      expect(subject.routing_key).not_to eq("")
      expect(subject.routing_key).not_to be_nil
    end
  end
end
