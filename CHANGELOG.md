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
