module QueueHelpers
  def create_stubs
    stub_environment_variables!
    queue = create_queue
    channel = create_channel(queue)
    conn = create_connection(channel)
    Stubs.new(channel: channel, queue: queue)
  end

  def create_connection(channel)
    rabbitmq_connecton = instance_double("Bunny::Session", start: nil, create_channel: channel)
    allow(Bunny).to receive(:new).and_return(rabbitmq_connecton)
    rabbitmq_connecton
  end

  def create_channel(queue)
    instance_double('Bunny::Channel', queue: queue, prefetch: nil, topic: nil)
  end

  def create_queue
    instance_double('Bunny::Queue', bind: nil, subscribe: '')
  end

  class Stubs
    attr_reader :channel, :queue

    def initialize(channel:, queue:)
      @channel = channel
      @queue = queue
    end
  end

end
