# -*- coding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'message_queue_consumer/version'

Gem::Specification.new do |s|
  s.name = "message-queue-consumer"
  s.version = MessageQueueConsumer::VERSION
  s.authors = ["Stuart Gale"]
  s.summary = "Simplify message queue consumption"
  s.description = "Avoid writing boilerplate code in order to consume messages from a queue. Plug in queue configuration, and how to process each message."
  s.homepage = "https://github.com/alphagov/message-queue-consumer"
  s.email = ["govuk-dev@digital.cabinet-office.gov.uk"]

  s.required_ruby_version = '2.2.3'

  s.files = Dir.glob("lib/**/*") + %w{README.md Rakefile}
  s.test_files = Dir["spec/*"]
  s.require_path = 'lib'

  s.add_dependency 'bunny', '~> 2.2.0'
  s.add_dependency 'activesupport', '~> 4.2.4'

  s.add_development_dependency 'gem_publisher', '~> 1.5.0'
  s.add_development_dependency 'rspec', '~> 3.3.0'
  s.add_development_dependency 'rake', '~> 10.4.2'
end
