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
