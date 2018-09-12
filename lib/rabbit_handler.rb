# frozen_string_literal: true

require 'bunny'
require 'json'

class RabbitHandler
  LAST_ADDRESS = 100 # There are up to one hundred test addresses per location

  def initialize(url, username, password)
    @connection = Bunny.new(hostname: url)
    @connection.start
    @channel = @connection.create_channel
    @queue = @channel.queue('jobsvc.job.request')
    @north_addresses = JSON.parse(File.read(File.join(__dir__, '../data/addresses_north.json')))
  end

  def close()
    @connection.close
  end

  def send_one(obj)
    json = obj.to_json
    @channel.default_exchange.publish(json, routing_key: @queue.name)
  end

  def run(form)
    for _ in 1..form[:count].to_i
      send_one(
        {
          actionType: "Create",
          jobIdentity: SecureRandom.hex(4),
          surveyType: form[:surveyType],
          preallocatedJob: false,
          mandatoryResourceAuthNo: form[:resNo],
          dueDate: (Time.now.to_date >> 1).to_time.iso8601,
          address: @north_addresses['addresses'][rand(1..LAST_ADDRESS)],
          additionalProperties: []
        }
      )
    end
  end
end
