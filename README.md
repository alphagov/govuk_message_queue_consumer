# GOV.UK Message Queue Consumer
[![Gem Version](https://badge.fury.io/rb/govuk_message_queue_consumer.svg)](https://badge.fury.io/rb/govuk_message_queue_consumer)

Standardises the way GOV.UK consumes messages from [RabbitMQ](https://www.rabbitmq.com/).
RabbitMQ is a messaging framework that allows applications to broadcast messages
that can be picked up by other applications.

On GOV.UK, [publishing-api](https://github.com/alphagov/publishing-api) publishes
the content-items it receives, so that applications such as
[email-alert-service](https://github.com/alphagov/email-alert-service) can be
notified of changes in content.

For detailed documentation, check out the [gem documentation on rubydoc.info](http://www.rubydoc.info/gems/govuk_message_queue_consumer/GovukMessageQueueConsumer/Consumer#initialize-instance_method).

This gem is used by:

- [Content Data API](https://github.com/alphagov/content-data-api).
- [Email Alert Service](https://github.com/alphagov/email-alert-service/).
- [Search API](https://github.com/alphagov/search-api).
- [Search API v2](https://github.com/alphagov/search-api-v2).

## Overview of RabbitMQ

To see an overview of RabbitMQ and how we use it, see [here](https://docs.publishing.service.gov.uk/manual/rabbitmq.html#overview).

## Technical documentation

This is a ruby gem that deals with the boiler plate code of communicating with
[RabbitMQ](https://www.rabbitmq.com/). The user of this gem is left the task of
supplying the configuration and a class that processes messages.

The gem is automatically released by Jenkins. To release a new version, raise a
pull request with the version number incremented.

### Dependencies

- The [Bunny](https://github.com/ruby-amqp/bunny) gem: to interact with RabbitMQ.

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

More options are [documented here](http://www.rubydoc.info/gems/govuk_message_queue_consumer/GovukMessageQueueConsumer/Consumer#initialize-instance_method).

The consumer expects the [`RABBITMQ_URL` environment
variable](https://github.com/ruby-amqp/bunny/blob/066496d/docs/guides/connecting.md#paas-environments)
to be set to an AMQP connection string, for example:

`RABBITMQ_URL=amqp://mrbean:hunter2@rabbitmq.example.com:5672`

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

The worker should also be added to the Procfile to run in production:

```
# Procfile
worker: bundle exec rake message_queue:consumer
```

Because you need the environment variables when running the consumer, you should use
`govuk_setenv` to run your app in development:

```
$ govuk_setenv app-name bundle exec rake message_queue:consumer
```

### Processing a message

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

### Statsd integration

You can pass a `statsd_client` to the `GovukMessageQueueConsumer::Consumer` initializer. The consumer will emit counters to statsd with these keys:

- `your_queue_name.started` - message picked up from the your_queue_name
- `your_queue_name.retried` - message has been retried
- `your_queue_name.acked` - message has been processed and acked
- `your_queue_name.discarded` - message has been discarded
- `your_queue_name.uncaught_exception` - an uncaught exception occured during processing

Remember to use a namespace for the `Statsd` client:

```ruby
statsd_client = Statsd.new("localhost")
statsd_client.namespace = "govuk.app.my_app_name"

GovukMessageQueueConsumer::Consumer.new(
  statsd_client: statsd_client
  # ... other setup code omitted
).run
```

### Testing your processor

This gem provides a test helper for your processor.

```ruby
# eg. spec/queue_consumers/my_processor_spec.rb
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

For more test cases [see the spec for the mock itself](/spec/mock_message_spec.rb).


### Running the test suite

```bash
bundle exec rake spec
```

## Further reading

- [Bunny](https://github.com/ruby-amqp/bunny) is the RabbitMQ client we use.
- [The Bunny Guides](http://rubybunny.info/articles/guides.html) explain all
  AMQP concepts really well.
- The [Developer Docs](https://docs.publishing.service.gov.uk/manual/rabbitmq.html)
  documents the usage of "heartbeat" messages, which this gem also supports.

## Licence

[MIT License](LICENCE)

## Versioning policy

We follow [Semantic versioning](http://semver.org/spec/v2.0.0.html). Check the
[CHANGELOG](CHANGELOG.md) for changes.
