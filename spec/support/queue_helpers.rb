module QueueHelpers
  def create_stubbed_queue
    stub_environment_variables!
    queue = instance_double('Bunny::Queue', bind: nil, subscribe: '')
    channel = instance_double('Bunny::Channel', queue: queue, prefetch: nil, topic: nil)
    rabbitmq_connecton = instance_double("Bunny::Session", start: nil, create_channel: channel)
    allow(Bunny).to receive(:new).and_return(rabbitmq_connecton)
    queue
  end
end
