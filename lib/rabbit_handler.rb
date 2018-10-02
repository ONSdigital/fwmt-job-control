# frozen_string_literal: true

require 'bunny'
require 'json'

class RabbitHandler
  CHANNEL_NAME = 'rm-jobsvc-exchange'
  ROUTING_KEY = 'jobsvc.job.request'

  def initialize(url, username, password)
    @connection = Bunny.new(hostname: url)
    @connection.start
    @channel = @connection.create_channel
    @exchange = @channel.topic(CHANNEL_NAME, durable: true)
  end

  def close()
    @connection.close
  end

  def send_one(obj)
    json = obj.to_json
    @exchange.publish(json, routing_key: ROUTING_KEY, persistent: true, content_type: 'text/plain')
  end

  # CCS jobs - postcode only

  def run(form)
    for i in 0..(form[:count].to_i - 1)
      addresses = AddressData.get_data_files.find { |f| f["name"] == "west" }["addresses"]
      address = addresses[i & addresses.length]
      message = {
        actionType: "Create",
        jobIdentity: SecureRandom.hex(4),
        surveyType: form[:surveyType],
        preallocatedJob: false,
        mandatoryResourceAuthNo: nil,
        dueDate: (Time.now + (60*60*24*1)).utc.iso8601,
        address: {
          line1: address['line1'],
          line2: address['line2'],
          line3: address['line3'],
          line4: address['line4'],
          townName: address['townName'],
          postCode: address['postcode'],
          latitude: address['latitude'],
          longitude: address['longitude'],
        },
      }
      p "Sending message: #{message}"
      send_one(message)
    end
  end
end
