# frozen_string_literal: true

require 'bunny'
require 'json'

class RabbitHandler
  CHANNEL_NAME = 'rm-jobsvc-exchange'
  ROUTING_KEY = 'jobsvc.job.request'

  def initialize(url, username, password, vhost)
    @connection = Bunny.new(hostname: url, username: username, password: password, vhost: vhost)
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
    survey_type = form[:survey_type]
    resno_gen = ResnoGenerator.new(form[:resno_kind], form[:resno_single], form[:resno_list])
    id_gen = IDGenerator.new(form[:id_kind], form[:id], form[:id_list], form[:id_incr_start])
    addr_gen = AddressGenerator.new(form[:addr_kind], form[:addr_strategy], form[:addr_single], form[:addr_preset], form[:addr_list], form[:addr_file])
    count = form[:count].nil? ? addr_gen.length : form[:count].to_i
    date_gen = DateGenerator.new(form[:due_date_kind], form[:due_date_set], form[:due_date_hours_ahead], form[:due_date_days_ahead])
    contact_gen = ContactGenerator.new(form[:contact_name], form[:contact_surname], form[:contact_email], form[:contact_phone_number])
    additional_properties = AddProps.hash_props(form[:additional_properties])
    request_gen = RabbitCreateGenerator.new(survey_type = survey_type,
                                            resno_gen = resno_gen,
                                            id_gen = id_gen,
                                            addr_gen = addr_gen,
                                            date_gen = date_gen,
                                            contact_gen = contact_gen,
                                            additional_properties = additional_properties,
                                            count = count)
    request_ids = []
    send = form[:send]
    (1..count).each do |i|
      request = request_gen.generate
      p "Sending message: #{request}"
      send_one(request)
      request_ids << request[:jobIdentity]
    end
    return request_ids
  end
end
