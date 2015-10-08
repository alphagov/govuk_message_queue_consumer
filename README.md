# Message Queue Consumer

Standardise the way GOV.UK consumes messages from RabbitMQ.


## Usage

Supply the RabbitMQ configuration, and an instance of the class that you want
to process the message.

The processing class supplied by the client:

- responds to `process` instance method
- receives a message of the form found in `lib/message_queue_consumer/message.rb`
