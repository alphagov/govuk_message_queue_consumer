require "spec_helper"

RSpec.describe GovukMessageQueueConsumer::RabbitMQConfig do
  describe ".from_environment" do
    it "provides a friendly error message when a variable is missing" do
      empty_hash = {}
      expect {
        described_class.from_environment(empty_hash)
      }.to raise_error(described_class::ConfigurationError)
    end

    it "connects to rabbitmq with the correct environment variables" do
      env = {
        "RABBITMQ_HOSTS" => "server-one,server-two",
        "RABBITMQ_VHOST" => "/",
        "RABBITMQ_USER" => "my_user",
        "RABBITMQ_PASSWORD" => "my_pass",
      }

      expect(described_class.from_environment(env)).to include({
        hosts: %w[server-one server-two],
        vhost: "/",
        user: "my_user",
        pass: "my_pass",
        recover_from_connection_close: true,
      })
    end

    it "defaults to not use TLS" do
      env = {
        "RABBITMQ_HOSTS" => "server-one,server-two",
        "RABBITMQ_VHOST" => "/",
        "RABBITMQ_USER" => "my_user",
        "RABBITMQ_PASSWORD" => "my_pass",
      }

      expect(described_class.from_environment(env).keys).not_to include(:tls)
    end

    context "when TLS environment variable is true" do
      let(:env) do
        {
          "RABBITMQ_HOSTS" => "server-one,server-two",
          "RABBITMQ_VHOST" => "/",
          "RABBITMQ_USER" => "my_user",
          "RABBITMQ_PASSWORD" => "my_pass",
          "RABBITMQ_TLS" => "true",
          "RABBITMQ_TLS_CERT" => "/path/to/cert",
          "RABBITMQ_TLS_KEY" => "/path/to/key",
          "RABBITMQ_TLS_CA_CERTIFICATES" => "/path/to/ca_cert1,/path/to/ca_cert2",
          "RABBITMQ_VERIFY_PEER" => "true",
        }
      end

      it "includes the given TLS values" do
        expect(described_class.from_environment(env)).to include({
          tls: true,
          tls_cert: "/path/to/cert",
          tls_key: "/path/to/key",
          verify_peer: "true",
        })
      end

      it "parses the given CA certificates as an array" do
        expect(described_class.from_environment(env)).to include({
          tls_ca_certificates: ["/path/to/ca_cert1", "/path/to/ca_cert2"],
        })
      end
    end
  end
end
