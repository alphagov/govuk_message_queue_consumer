require_relative '../lib/message_queue_consumer'

include MessageQueueConsumer

module TestHelpers
  def rabbitmq_config
    {
      "connection" => {
        "hosts" => ["rabbitmq1.example.com", "rabbitmq2.example.com"],
        "port" => 5672,
        "vhost" => "/",
        "user" => "a_user",
        "pass" => "super secret",
        "recover_from_connection_close" => true,
      },
      "queue" => "content_register",
      "exchange" => "published_documents",
    }
  end

  def message_values
    [:delivery_info1, :headers1, "message1_body"]
  end
end

RSpec.configure do |c|
  c.include TestHelpers
end
