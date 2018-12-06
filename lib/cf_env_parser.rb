# frozen_string_literal: true

module CfEnvParser
  def self.parse_services
    string = ENV['VCAP_SERVICES']
    return nil if string.nil?
    json = JSON.parse(string)
    url = json['rabbitmq'][0]['credentials']['protocols']['amqp']['host']
    port = json['rabbitmq'][0]['credentials']['protocols']['amqp']['port']
    return {
      rabbit_url:      "#{url}:#{port}",
      rabbit_username: json['rabbitmq'][0]['credentials']['protocols']['amqp']['username'],
      rabbit_password: json['rabbitmq'][0]['credentials']['protocols']['amqp']['password'],
      rabbit_vhost:    json['rabbitmq'][0]['credentials']['protocols']['amqp']['vhost']
    }
  end

  def self.parse_application
    string = ENV['VCAP_APPLICATION']
    return nil if string.nil?
    json = JSON.parse(string)
    return {
      space: json['space_name']
    }
  end
end
