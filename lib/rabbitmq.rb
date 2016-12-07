class BunnyEmitter

  def initialize(queue_name)
    @connection = Bunny.new("amqp://guest@172.25.0.2:5672")
    @connection.start
    @channel = @connection.create_channel
    @exchange = @channel.default_exchange
    @queue = @channel.queue(queue_name, :exclusive => true)
    # @queue.bind(@exchange)
  end

  def publish(message)
    @exchange.publish(message)
    puts "[X] Sent: #{message}"
  end

  def close
    @connection.close
    @channel.close
  end
end

