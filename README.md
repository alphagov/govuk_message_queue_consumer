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
    config = get_rabbitmq_configuration_hash
    # ^ eg YAML.load_file(Rails.root.join('config', 'rabbitmq.yml'))[Rails.env].with_indifferent_access
    GovukMessageQueueConsumer::Consumer.new(config, MyProcessor.new).run
  end
end
```

`govuk_message_queue_consumer` expects configuration and a processor to be supplied:

```ruby
# example configuration. Could be stored in YAML if preferred
config = {
    host: 'localhost',
    port: 5672,
    user: rabbitmq_user,
    pass: rabbitmq_pass,
    recover_from_connection_close: true,
    exchange: my_exchange,
    queue: my_queue,
}

# example message processor
class MyProcessor
  def process(message)
    message.ack
  end
end
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

### Running the test suite

```bash
bundle exec rake spec
```


## Licence

[MIT License](LICENCE)


## Versioning policy

[Semantic versioning](http://semver.org/spec/v2.0.0.html)
