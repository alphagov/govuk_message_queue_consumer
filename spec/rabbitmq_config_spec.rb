require 'spec_helper'

RSpec.describe RabbitMQConfig do
  describe ".from_environment" do
    it "connects to rabbitmq with the correct environment variables" do
      ENV["RABBITMQ_HOSTS"] = "server-one,server-two"
      ENV["RABBITMQ_VHOST"] = "/"
      ENV["RABBITMQ_USER"] = "my_user"
      ENV["RABBITMQ_PASSWORD"] = "my_pass"

      expect(RabbitMQConfig.new.from_environment).to eql({
        hosts: ["server-one", "server-two"],
        vhost: "/",
        user: "my_user",
        pass: "my_pass",
        recover_from_connection_close: true,
      })
    end

    it "provides a friendly error message when a variable is missing" do
      ENV["RABBITMQ_HOSTS"] = nil

      expect { RabbitMQConfig.new.from_environment }.to raise_error(RabbitMQConfig::ConfigurationError)
    end
  end
end
