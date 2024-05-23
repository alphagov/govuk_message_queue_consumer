# 5.0.1
- Add explicit require for `ostruct` library to `MockMessage` (previously relied on `ostruct` being
  required somewhere in consuming code)

# 5.0.0

- BREAKING: remove disused support for statsd. No clients in alphagov use the statsd functionality any more, so this is only theoretically breaking.
- Allow clients to specify a Bunny worker thread pool size of greater than 1. The default behaviour remains unchanged.
- Allow clients to specify "client prefetch" to allow more than one unacked message on a channel at a time. The default behaviour remains unchanged.
- Clean up some disused remnants of the batch consumer feature. The feature was removed in 4.0.0.

# 4.2.0

* Drop support for Ruby 3.0. The minimum required Ruby version is now 3.1.4.
* Add support for Ruby 3.3.
- Drop support for Ruby 2.7.
- Fix ability to handle system signals, and report non-`SIGTERM` errors to `GovukError`

# 4.1.0

- Support configuration via
  [`RABBITMQ_URL`](https://github.com/ruby-amqp/bunny/blob/066496d8/docs/guides/connecting.md#the-rabbitmq_url-environment-variable)
  instead of `RABBITMQ_HOSTS`, `RABBITMQ_VHOST`, `RABBITMQ_USER` and
  `RABBITMQ_PASSWORD`, which are deprecated and will be removed in a later
  version.
- Update [bunny](https://github.com/ruby-amqp/bunny/) from 2.11 to 2.17, which
  is the last version that supports Ruby 2.7. See [Bunny
  changelog](https://github.com/ruby-amqp/bunny/blob/main/ChangeLog.md#changes-between-bunny-216x-and-2170-sep-11th-2020).

# 4.0.0

- Breaking: remove batch consumer ([#73](https://github.com/alphagov/govuk_message_queue_consumer/pull/73))

# 3.5.0

- Stop reporting `SignalExceptions` to `GovukError`.

# 3.4.0

- Add ability to override default consumer subscribe options with `subscribe_opts` parameter

# 3.3.0

- Add access to `payload`, `delivery_info`, `header` in `GovukMessageQueueConsumer::MockMessage` for testing.

# 3.2.1

- Upgrade [bunny](http://rubybunny.info/) to 2.11

# 3.2.0

- Add batch process capabilities
- Refactor `process_chain` to `message_consumer`

# 3.1.0

- Change Airbrake to GovukError

# 3.0.2

- Republish 3.0.1 to correct checksum.

# 3.0.1

- Fix a bug that caused the test-helpers to error ([#34](https://github.com/alphagov/govuk_message_queue_consumer/pull/34))

# 3.0.0

- Updated README to conform changes on [PR #32](https://github.com/alphagov/govuk_message_queue_consumer/pull/32)
- Remove `exchange_name` parameter [PR #34](https://github.com/alphagov/govuk_message_queue_consumer/pull/34)
- Don't build test files in the gem [PR #33](https://github.com/alphagov/govuk_message_queue_consumer/pull/33)
- Prevent consumer from creating rabbitmq queues or bindings [PR #32](https://github.com/alphagov/govuk_message_queue_consumer/pull/32)

# 2.1.0

- Add support for sending stats to Statsd

# 2.0.1

* Add support for Airbrake.

# 2.0.0

- README updates making it clearer how to use the gem
- Use environment variables for RabbitMQ configuration
- Use keyword arguments for the `Consumer` setup
- Add rspec shared examples for testing a message processor
- Add `GovukMessageQueueConsumer::MockMessage` for easy testing
- Add `GovukMessageQueueConsumer::JSONProcessor` as an intermediate processor for JSON payloads
- Add Airbrake notification for gem errors
- Remove active_support dependency

# 1.0.0

- Rename the gem to `govuk_message_queue_consumer`
- Make test helpers easier to use
- Readme improvements
- Initial release!

# 0.9.1

Bug fix:
- relax the ruby version as it's causing problems in projects trying to use it


# 0.9.0

- Initial implementation of the gem
