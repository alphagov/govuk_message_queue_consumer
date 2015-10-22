if defined?(RSpec)
  RSpec.shared_examples "a message queue processor" do
    it "implements #process" do
      expect(subject).to respond_to(:process)
    end

    it "accepts 1 argument for #process" do
      expect(subject.method(:process).arity).to eq(1)
    end
  end
end
