# GOV.UK Message queue consumer

Standardise the way GOV.UK consumes messages from RabbitMQ.


## Nomenclature

- **Message queue**: a method of providing asynchronous interprocess
  communication


## Technical documentation

This is a ruby gem that deals with the boiler plate code of connecting,
subscribing, etc, to [RabbitMQ](https://www.rabbitmq.com/).

The user of this gem is left the task of supplying their rabbitmq infrastructure
configuration and an instance of a class that processes messages.

The message format received by the message processor is found in
`lib/govuk_message_queue_consumer/message.rb`

### Dependencies

- **bunny**: to interact with RabbitMQ
- **activesupport**: use `with_indifferent_access` for Bunny

### Running the application

We recommend creating a rake task like the following example:

```ruby
namespace :message_queue do
  desc "Run worker to consume messages from rabbitmq"
  task consumer: :environment do
    GovukMessageQueueConsumer::Consumer.new(
      queue_name: "some-queue",
      exchange: "some-exchange",
      processor: MyProcessor.new
    ).run
  end
end
```

The consumer expects a number of environment variables to be present:

```
RABBITMQ_HOSTS=rabbitmq1.example.com,rabbitmq2.example.com
RABBITMQ_VHOST=/
RABBITMQ_USER=a_user
RABBITMQ_PASSWORD=a_super_secret
```

Define a class that will process the messages:

```ruby
# example message processor
class MyProcessor
  def process(message)
    message.ack
  end
end
```

Because you need the environment variables when running the consumer, you should use
`govuk_setenv` to run your app:

```
$ govuk_setenv app-name bundle exec rake message_queue:consumer
```

#### Testing your processor

This gem provides a test helper for your processor.

```ruby
require 'test_helper'
require 'govuk_message_queue_consumer/test_helpers'

describe MyProcessor do
  it_behaves_like "a message queue processor"
end
```

This will verify that your processor class implements the correct methods. You should add your own tests to verify its behaviour.

You can use `GovukMessageQueueConsumer::MockMessage` to test the processor behaviour. When using the mock, you can verify it acknowledged, retried or discarded. For example, with `MyProcessor` above:

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


## Licence

[MIT License](LICENCE)


## Versioning policy

[Semantic versioning](http://semver.org/spec/v2.0.0.html)
