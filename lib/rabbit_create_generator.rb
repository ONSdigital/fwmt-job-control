# frozen_string_literal: true

require 'bunny'
require 'json'

class RabbitCreateGenerator
  def initialize(survey_type, resno_gen, id_gen, addr_gen, date_gen, count)
    @survey_type = survey_type
    @resno_gen = resno_gen
    @id_gen = id_gen
    @addr_gen = addr_gen
    @date_gen = date_gen
    @count = count
  end

  # CCS jobs - postcode only

  def generate
    resno = @resno_gen.generate
    id = @id_gen.generate
    address = @addr_gen.generate
    date = @date_gen.generate
    {
      actionType: 'Create',
      jobIdentity: id,
      surveyType: @survey_type,
      preallocatedJob: false,
      mandatoryResourceAuthNo: resno,
      dueDate: date,
      address: address
    }
  end
end
