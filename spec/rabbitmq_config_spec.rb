require "spec_helper"

module GovukMessageQueueConsumer
  RSpec.describe RabbitMQConfig do
    describe ".from_environment" do
      it "provides a friendly error message when a variable is missing" do
        empty_hash = {}
        expect {
          described_class.from_environment(empty_hash)
        }.to raise_error(RabbitMQConfig::ConfigurationError)
      end

      it "connects to rabbitmq with the correct environment variables" do
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
          recover_from_connection_close: true,
        })
      end
    end
  end
end
