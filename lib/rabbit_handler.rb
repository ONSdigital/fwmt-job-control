# frozen_string_literal: true

require 'bunny'

class RabbitHandler
  def self.perform(server, user_name, password, job_id, message)
    connection = Bunny.new(hostname: server)
    connection.start
    channel = connection.create_channel
    queue = channel.queue('jobsvc.job.request')
    channel.default_exchange.publish('test', routing_key: queue.name)
    connection.close
  end
end
