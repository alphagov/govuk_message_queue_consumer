require "spec_helper"

RSpec.describe GovukMessageQueueConsumer::RabbitMQConfig do
  describe ".from_environment" do
    it "provides a friendly error message when a variable is missing" do
      empty_hash = {}
      expect {
        described_class.from_environment(empty_hash)
      }.to raise_error(described_class::ConfigurationError)
    end

    it "produces the expected configuration from legacy govuk RABBITMQ_x env vars" do
      env = {
        "RABBITMQ_HOSTS" => "server-one,server-two",
        "RABBITMQ_VHOST" => "/",
        "RABBITMQ_USER" => "my_user",
        "RABBITMQ_PASSWORD" => "my_pass",
      }

      expect(described_class.from_environment(env)).to eql({
        hosts: %w[server-one server-two],
        vhost: "/",
        user: "my_user",
        pass: "my_pass",
      })
    end
  end
end
