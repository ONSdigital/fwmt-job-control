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
    survey_type = form[:surveyType]
    resno_gen = ResnoGenerator(form[:resNoKind], form[:resNo], form[:resNoList])
    id_gen = IDGenerator(form[:idKind], form[:id], form[:idList], form[:idIncrStart])
    addr_gen = AddressGenerator(form[:addrKind], form[:addrStrategy], form[:addr], form[:addrPreset], form[:addrList], form[:addrFile])
    request_gen = RabbitCreateGenerator.initialize(survey_type, resno_gen, id_gen, addr_gen)
    for i in 0..(form[:count].to_i - 1)
      request = request_gen.generate
      p "Iteration: #{i}"
      p "Sending message: #{request}"
      send_one(request)
    end
  end
end
