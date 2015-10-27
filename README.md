# GOV.UK Message Queue Consumer

Standardises the way GOV.UK consumes messages from [RabbitMQ](https://www.rabbitmq.com/).
RabbitMQ is a messaging framework that allows applications to broadcast messages
that can be picked up by other applications.

On GOV.UK, [publishing-api](https://github.com/alphagov/publishing-api) publishes
the content-items it receives, so that applications such as
[email-alert-service](https://github.com/alphagov/email-alert-service) can be
notified of changes in content.

## Nomenclature

![A graph showing the message flow](docs/graph.png)

- **Producer**: an application that sends messages RabbitMQ. On GOV.UK this could
  be [publishing-api](https://github.com/alphagov/publishing-api).
- **Message**: an object sent over RabbitMQ. It consists of a _payload_ and
  _headers_. In the case of the publishing-api the payload is a
  [content item](https://github.com/alphagov/govuk-content-schemas).
- **Consumer**: the app that receives the messages and does something with them.
  On GOV.UK, these could be [email-alert-service](https://github.com/alphagov/email-alert-service)
  and [content-register](https://github.com/alphagov/content-register).
- **Exchange**: in RabbitMQ's model, producers send messages to an _exchange_.
  Consumers can create a Queue that listens to the exchange, instead of
  subscribing to the exchange directly. This is done so that the queue can buffer
  any messages and we can make sure all messages get delivered to the consumer.
- **Queue**: a queue listens to an exchange. In most cases the queue will listen
  to all messages, but it's also possible to listen to a specific pattern.
- **Processor**: the specific class that processes a message.

## Technical documentation

This is a ruby gem that deals with the boiler plate code of communicating with
[RabbitMQ](https://www.rabbitmq.com/). The user of this gem is left the task of
supplying the configuration and a class that processes messages.

This gem is auto-released with [gem_publisher](https://github.com/alphagov/gem_publisher).
To release a new version, simply raise a pull request with the version number
incremented.

### Dependencies

- The [Bunny](https://github.com/ruby-amqp/bunny) gem: to interact with RabbitMQ.

## Usage

For an example on how to implement a message queue consumer, see [alphagov/panopticon#307](https://github.com/alphagov/panopticon/pull/307/files).

Add the gem:

```ruby
# Gemfile
gem "govuk_message_queue_consumer", "~> 2.0.0"
```

Add a rake task like the following example:

```ruby
# lib/tasks/message_queue.rake
namespace :message_queue do
  desc "Run worker to consume messages from rabbitmq"
  task consumer: :environment do
    GovukMessageQueueConsumer::Consumer.new(
      queue_name: "some-queue",
      exchange_name: "some-exchange",
      processor: MyProcessor.new
    ).run
  end
end
```

The consumer expects a number of environment variables to be present. On GOV.UK,
these should be set up in puppet.

```
RABBITMQ_HOSTS=rabbitmq1.example.com,rabbitmq2.example.com
RABBITMQ_VHOST=/
RABBITMQ_USER=a_user
RABBITMQ_PASSWORD=a_super_secret
```

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
- The [Opsmanual](https://github.gds/pages/gds/opsmanual/2nd-line/nagios.html?highlight=rabbitmq#rabbitmq-checks)
  documents the usage of "heartbeat" messages, which this gem also supports.

## Licence

[MIT License](LICENCE)

## Versioning policy

We follow [Semantic versioning](http://semver.org/spec/v2.0.0.html). Check the
[CHANGELOG](CHANGELOG.md) for changes.
