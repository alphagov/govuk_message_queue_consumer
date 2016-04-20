module QueueHelpers
  def create_bunny_stubs
    stub_environment_variables!
    queue = create_queue
    channel = create_channel(queue)
    conn = create_connection(channel)
    BunnyStubs.new(connection: conn, channel: channel, queue: queue)
  end

  def create_connection(channel)
    instance_double("Bunny::Session", start: nil, create_channel: channel)
  end

  def create_channel(queue)
    instance_double('Bunny::Channel', queue: queue, prefetch: nil, topic: nil)
  end

  def create_queue
    instance_double('Bunny::Queue', bind: nil, subscribe: '')
  end

  class BunnyStubs
    attr_reader :connection, :channel, :queue

    def initialize(connection:, channel:, queue:)
      @connection = connection
      @channel = channel
      @queue = queue
    end
  end

end
