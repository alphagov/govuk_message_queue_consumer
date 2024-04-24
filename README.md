# GOV.UK Message Queue Consumer

[![Gem Version](https://badge.fury.io/rb/govuk_message_queue_consumer.svg)](https://badge.fury.io/rb/govuk_message_queue_consumer)

govuk_message_queue_consumer is a wrapper around the
[Bunny](https://github.com/ruby-amqp/bunny) gem for communicating with
[RabbitMQ](https://www.rabbitmq.com/). The user of govuk_message_queue_consumer
supplies some configuration and a class that processes messages.

RabbitMQ is a multi-producer, multi-consumer message queue that allows
applications to subscribe to notifications published by other applications.

GOV.UK [publishing-api](https://github.com/alphagov/publishing-api) publishes
a message to RabbitMQ when a ContentItem is added or changed. Other
applications (consumers) subscribe to these messages so that they can perform
actions such as emailing users or updating a search index.

Several GOV.UK applications use govuk_message_queue_consumer:

- [Content Data API](https://github.com/alphagov/content-data-api)
- [Email Alert Service](https://github.com/alphagov/email-alert-service/)
- [Search API](https://github.com/alphagov/search-api)
- [Search API v2](https://github.com/alphagov/search-api-v2)

## Technical documentation

You can browse the [API documentation on
rubydoc.info](http://www.rubydoc.info/gems/govuk_message_queue_consumer/GovukMessageQueueConsumer/Consumer#initialize-instance_method).

## Release a new version

To release a new version, increment the [version
number](/lib/govuk_message_queue_consumer/version.rb) and raise a pull request.

The [CI GitHub Actions
workflow](https://github.com/alphagov/govuk_message_queue_consumer/actions/workflows/ci.yml)
should automatically build and push the new release when you merge the PR.

## Usage

[Add the gem to your Gemfile](https://rubygems.org/gems/govuk_message_queue_consumer).

Add a rake task like the following example:

```ruby
# lib/tasks/message_queue.rake
namespace :message_queue do
  desc "Run worker to consume messages from rabbitmq"
  task consumer: :environment do
    GovukMessageQueueConsumer::Consumer.new(
      queue_name: "some-queue",
      processor: MyProcessor.new,
    ).run
  end
end
```

See the [API documentation](http://www.rubydoc.info/gems/govuk_message_queue_consumer/GovukMessageQueueConsumer/Consumer#initialize-instance_method) for the full list of parameters.

`GovukMessageQueueConsumer::Consumer` expects the [`RABBITMQ_URL` environment
variable](https://github.com/ruby-amqp/bunny/blob/066496d/docs/guides/connecting.md#paas-environments)
to be set to an AMQP connection string, for example:

```sh
RABBITMQ_URL=amqp://mrbean:hunter2@rabbitmq.example.com:5672
```

The GOV.UK-specific environment variables `RABBITMQ_HOSTS`, `RABBITMQ_VHOST`,
`RABBITMQ_USER` and `RABBITMQ_PASSWORD` are deprecated. Support for these will
be removed in a future version of govuk_message_queue_consumer.

Define a class that will process the messages:

```ruby
# eg. app/queue_consumers/my_processor.rb
class MyProcessor
  def process(message)
    # do something cool
  end
end
```

You can start the worker by running the `message_queue:consumer` Rake task.

```sh
bundle exec rake message_queue:consumer
```

### Process a message

Once you receive a message, you *must* tell RabbitMQ once you've processed it. This
is called _acking_. You can also _discard_ the message, or _retry_ it.

```ruby
class MyProcessor
  def process(message)
    result = do_something_with(message)

    if result.ok?
      # Ack the message when it has been processed correctly.
      message.ack
    elsif result.failed_temporarily?
      # Retry the message to make RabbitMQ send the message again later.
      message.retry
    elsif result.failed_permanently?
      # Discard the message when it can't be processed.
      message.discard
    end
  end
end
```

### Test your processor

govuk_message_queue_consumer provides a test helper for your processor.

```ruby
# e.g. spec/queue_consumers/my_processor_spec.rb
require 'test_helper'
require 'govuk_message_queue_consumer/test_helpers'

describe MyProcessor do
  it_behaves_like "a message queue processor"
end
```

This will verify that your processor class implements the correct methods. You
should add your own tests to verify its behaviour.

You can use `GovukMessageQueueConsumer::MockMessage` to test the processor
behaviour. When using the mock, you can verify it acknowledged, retried or
discarded. For example, with `MyProcessor` above:

```ruby
it "acks incoming messages" do
  message = GovukMessageQueueConsumer::MockMessage.new

  MyProcessor.new.process(message)

  expect(message).to be_acked

  # or if you use minitest:
  assert message.acked?
end
```

For more test cases [see the spec for the mock itself](/spec/govuk_message_queue_consumer/test_helpers/mock_message_spec.rb).

### Run the test suite

```bash
bundle exec rake spec
```

## Further reading

- [Bunny](https://github.com/ruby-amqp/bunny) is the RabbitMQ client we use.
- [The Bunny Guides](https://github.com/ruby-amqp/bunny/tree/main/docs/guides) explain
  AMQP concepts.

## Licence

[MIT License](LICENCE)

## Versioning policy

We follow [Semantic versioning](http://semver.org/spec/v2.0.0.html). Check the
[CHANGELOG](CHANGELOG.md) for changes.
