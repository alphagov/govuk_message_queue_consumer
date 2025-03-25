lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require "govuk_message_queue_consumer/version"

Gem::Specification.new do |s|
  s.name = "govuk_message_queue_consumer"
  s.version = GovukMessageQueueConsumer::VERSION
  s.authors = ["GOV.UK Dev"]
  s.summary = "AMQP message queue consumption with GOV.UK conventions"
  s.description = "Avoid writing boilerplate code in order to consume messages from an AMQP message queue. Plug in queue configuration, and how to process each message."
  s.homepage = "https://github.com/alphagov/govuk_message_queue_consumer"
  s.email = ["govuk-dev@digital.cabinet-office.gov.uk"]
  s.required_ruby_version = ">= 3.1.4"

  s.files = Dir.glob("lib/**/*") + %w[LICENCE README.md CHANGELOG.md]
  s.require_path = "lib"

  s.add_dependency "bunny", "~> 2.17"
  s.add_dependency "ostruct"

  s.add_development_dependency "bunny-mock"
  s.add_development_dependency "pry-byebug"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 3.11"
  s.add_development_dependency "rubocop-govuk", "5.1.1"
  s.add_development_dependency "yard"
end
