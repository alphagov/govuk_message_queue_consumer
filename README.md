# Message queue consumer

Standardise the way GOV.UK consumes messages from RabbitMQ.


## Nomenclature

- **Message queue**: a method of providing asynchronous interprocess
  communication


## Technical documentation

This is a ruby gem that deals with the boiler plate code of connecting,
subscribing, etc, to [RabbitMQ](https://www.rabbitmq.com/).

The user of this gem is left the task of supplying their rabbitmq infrastructure
configuration and a class that processes messages.

The message format received by the client processor is found in
`lib/message_queue_consumer/message.rb`


### Dependencies

- **bunny**: to interact with RabbitMQ
- **activesupport**: use `with_indifferent_access` for Bunny


### Running the application

Example usage:

```ruby
config = {
    host: 'localhost',
    port: 5672,
    user: rabbitmq_user,
    pass: rabbitmq_pass,
    recover_from_connection_close: true,
    exchange: my_exchange,
    queue: my_queue,
}

class Processor
  def process(message)
    message.ack
  end
end

consumer = MessageQueueConsumer::Consumer.new(config, Processor.new)
consumer.run
```


### Running the test suite

```
bundle exec rake spec
```


## Licence

[MIT License](LICENCE)


## Versioning policy

[Semantic versioning](http://semver.org/spec/v2.0.0.html)
