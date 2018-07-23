# frozen_string_literal: true

require 'rest-client'

# Class encapsulating a job SOAP request.
class JobRequest
  DUE_DATE = '2018-07-31T23:59:59'
  ENDPOINT = 'services/tm/v20/messaging/MessageQueueWs.asmx'
  SOAP_ACTION = 'http://schemas.consiliumtechnologies.com/wsdl/mobile/2007/07/messaging/SendCreateJobRequestMessage'

  def initialize(params, message_template)
    @server     = params['server']
    @user_name  = params['user_name']
    @password   = params['password']
    @survey     = params['survey']
    @world      = params['world']
    @user_names = params['user_names']
    @job_count  = params['job_count'].to_i
    @location   = params['location']
    @message_template = message_template
  end

  def send_create_message
    user_names = @user_names.split(',')
    user_names.each do |user_name|
      1.upto(@job_count) do
        job_id = SecureRandom.hex(4)

        case @survey
        when 'CCS'
        when 'GFF'
          response = send_gff_create_message(job_id, user_name)
        when 'HH'
        when 'LFS'
        end
      end
    end
  end

  private

  def send_gff_create_message(job_id, user_name)
    variables = { job_id: job_id,
                  address: nil,
                  postcode: 'PO15 5RR',
                  tla: 'SLC',
                  due_date: DUE_DATE,
                  work_type: 'SS',
                  user_name: user_name,
                  world: @world,
                  additional_properties: nil }

    message = ERB.new(File.read(@message_template)).result(OpenStruct.new(variables).instance_eval { binding })
    send_create_message(message)
  end

  def send_create_message(message)
    RestClient::Request.execute(method: :post,
                                url: "#{@server}/#{ENDPOINT}",
                                user: @user_name,
                                password: @password,
                                headers: { 'SOAPAction': SOAP_ACTION, 'Content-Type': 'text/xml' },
                                payload: message)
  end
end
