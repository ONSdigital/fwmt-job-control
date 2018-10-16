# frozen_string_literal: true

require 'bunny'
require 'json'

class RabbitHandler
  CHANNEL_NAME = 'rm-jobsvc-exchange'
  ROUTING_KEY = 'jobsvc.job.request'

  def initialize(url, username, password)
    @connection = Bunny.new(hostname: url, username: username, password: password)
    @connection.start
    @channel = @connection.create_channel
    @exchange = @channel.direct(CHANNEL_NAME, durable: true)
  end

  def close
    @connection.close
  end

  def send_one(obj)
    json = obj.to_json
    @exchange.publish(json, routing_key: ROUTING_KEY, persistent: true, content_type: 'text/plain')
  end

  # CCS jobs - postcode only

  def run(form)
    survey_type = form[:surveyType]
    resno_gen = ResnoGenerator.new(form[:resNoKind], form[:resNo], form[:resNoList])
    id_gen = IDGenerator.new(form[:idKind], form[:id], form[:idList], form[:idIncrStart])
    addr_gen = AddressGenerator.new(form[:addrKind], form[:addrStrategy], form[:addr], form[:addrPreset], form[:addrList], form[:addrFile])
    date_gen = DateGenerator.new(form[:dueDateKind], form[:dueDate], form[:dueDateHours], form[:dueDateDays])
    request_gen = RabbitCreateGenerator.new(survey_type, resno_gen, id_gen, addr_gen, date_gen, form[:count].to_i)
    requests = []
    send = form[:send]
    (1..form[:count].to_i).each do |i|
      request = request_gen.generate
      p "Iteration: #{i}"
      p "Sending message: #{request}"
      send_one(request) if send
      requests << request unless send
    end
    return requests unless send
  end
end
