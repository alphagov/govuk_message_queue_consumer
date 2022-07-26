require_relative "../lib/govuk_message_queue_consumer"

include GovukMessageQueueConsumer
require "bunny-mock"
require "pry"
BunnyMock.use_bunny_queue_pop_api = true

module TestHelpers
  def stub_environment_variables!
    ENV["RABBITMQ_HOSTS"] ||= ""
    ENV["RABBITMQ_VHOST"] ||= "/"
    ENV["RABBITMQ_USER"] ||= "/"
    ENV["RABBITMQ_PASSWORD"] ||= "/"
  end
end

RSpec.configure do |c|
  c.include TestHelpers
  c.order = "random"
end
