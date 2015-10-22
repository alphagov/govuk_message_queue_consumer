require_relative '../lib/govuk_message_queue_consumer'

include GovukMessageQueueConsumer

module TestHelpers
  def stub_environment_variables!
    ENV["RABBITMQ_HOSTS"] ||= ""
    ENV["RABBITMQ_PORT"] ||= ""
    ENV["RABBITMQ_VHOST"] ||= "/"
    ENV["RABBITMQ_USER"] ||= "/"
    ENV["RABBITMQ_PASSWORD"] ||= "/"
  end
end

RSpec.configure do |c|
  c.include TestHelpers
end
