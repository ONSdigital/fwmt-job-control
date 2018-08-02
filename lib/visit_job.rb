# frozen_string_literal: true

require 'rest-client'

require_relative 'message'

ENDPOINT ||= 'services/tm/v20/messaging/MessageQueueWs.asmx'
CREATE_SOAP_ACTION = 'http://schemas.consiliumtechnologies.com/wsdl/mobile/2007/07/messaging/SendCreateJobRequestMessage'

# Sucker Punch job class for sending create job visit requests to the FWMT asynchronously.
class VisitJob
  include SuckerPunch::Job
  include Message

  def perform(server, user_name, password, job_id, message)
    response = RestClient::Request.execute(method: :post,
                                           url: "#{server}/#{ENDPOINT}",
                                           user: user_name,
                                           password: password,
                                           headers: { 'SOAPAction': CREATE_SOAP_ACTION, 'Content-Type': 'text/xml' },
                                           payload: message)

    message_id = get_message_id(response)
    logger.info "Totalmobile returned message ID '#{message_id}' in response to SendCreateJobRequestMessage for job '#{job_id}'"
  rescue RestClient::Unauthorized
    logger.error 'Invalid Totalmobile server credentials'
  end
end
