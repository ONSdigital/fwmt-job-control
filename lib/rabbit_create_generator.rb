# frozen_string_literal: true

require 'bunny'
require 'json'

class RabbitCreateGenerator
  def initialize(survey_type, resno_gen, id_gen, addr_gen, date_gen)
    @survey_type = survey_type
    @resno_gen = resno_gen
    @id_gen = id_gen
    @addr_gen = addr_gen
    @date_gen = date_gen
  end

  # CCS jobs - postcode only

  def generate()
    for i in 0..(form[:count].to_i - 1)
      addresses = AddressData.get_data_files.find { |f| f["name"] == "west" }["addresses"]
      address = addresses[i & addresses.length]
      resno = @resno_gen.generate
      id = @id_gen.generate
      address = @address_gen.generate
      date = @date_gen.generate
      return {
        actionType: "Create",
        jobIdentity: id,
        surveyType: @survey_type,
        preallocatedJob: false,
        mandatoryResourceAuthNo: resno,
        dueDate: date,
        address: address,
      }
    end
  end
end
