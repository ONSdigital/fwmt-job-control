# frozen_string_literal: true

require 'bunny'
require 'json'

class RabbitCreateGenerator
  def initialize(survey_type, resno_gen, id_gen, addr_gen, date_gen, contact_gen, additional_properties, count)
    @survey_type = survey_type
    @resno_gen = resno_gen
    @id_gen = id_gen
    @addr_gen = addr_gen
    @date_gen = date_gen
    @contact_gen = contact_gen
    @additional_properties = additional_properties
    @count = count
  end

  # CCS jobs - postcode only

  def generate
    resno = @resno_gen.generate
    id = @id_gen.generate
    address = @addr_gen.generate
    date = @date_gen.generate
    contact = @contact_gen.generate
    additional_properties = @additional_properties
    msg = {
      actionType: 'Create',
      jobIdentity: id,
      surveyType: @survey_type,
      preallocatedJob: false,
      mandatoryResourceAuthNo: resno,
      dueDate: date,
      address: address
    }
    msg[:contact] = contact if not contact.nil?
    msg[:additionalProperties] = additional_properties if not additional_properties.nil?
    return msg
  end
end
