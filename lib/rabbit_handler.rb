# frozen_string_literal: true

require 'bunny'
require 'json'

class RabbitHandler
  CHANNEL_NAME = ''
  ROUTING_KEY = ''

  def initialize(url, username, password)
    @connection = Bunny.new(hostname: url)
    @connection.start
    @channel = @connection.create_channel
    @exchange = @channel.topic('rm-jobsvc-exchange', durable: true)
    @north_addresses = JSON.parse(File.read(File.join(__dir__, '../data/addresses_north.json')))
  end

  def close()
    @connection.close
  end

  def send_one(obj)
    json = obj.to_json
    @exchange.publish(json, routing_key: 'jobsvc.job.request', persistent: true, content_type: 'text/plain')
  end

  def run(form)
    for i in 0..(form[:count].to_i - 1)
      # address = @north_addresses['addresses'][rand(1..LAST_ADDRESS)]
      postcodes = POSTCODES_CENSUS_4
      postcode = postcodes[i % postcodes.length]
      message = {
        actionType: "Create",
        jobIdentity: SecureRandom.hex(4),
        surveyType: form[:surveyType],
        preallocatedJob: false,
        mandatoryResourceAuthNo: nil,
        dueDate: Time.now.utc.iso8601,
        address: {postCode: postcode},
      }
      p "Sending message: #{message}"
      send_one(message)
    end
  end
end
