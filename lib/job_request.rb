# frozen_string_literal: true

require 'time'
require 'json'

require_relative 'visit_job'
require_relative 'update_job'

# Class encapsulating a job SOAP request.
class JobRequest
  CREATE_MESSAGE_TEMPLATE = File.join(__dir__, '../views/create_job_request.xml.erb')
  UPDATE_MESSAGE_TEMPLATE = File.join(__dir__, '../views/update_job_header_request.xml.erb')
  DUE_DATE = (Time.now.to_date >> 1).to_time.iso8601 # One month from now
  LAST_ADDRESS = 100 # There are up to one hundred test addresses per location

  def initialize(server, user_name, password)
    @server    = server
    @user_name = user_name
    @password  = password
  end

  def send_create_message(survey, world, user_names, job_count, location)
    @location = location
    load_address_files

    user_names = user_names.split(',')
    user_names.each do |user_name|
      1.upto(job_count.to_i) do
        job_id = SecureRandom.hex(4)

        # Dynamically dispatch to the private method for the survey.
        method_name = "send_#{survey.downcase}_create_message"
        send(method_name, job_id, user_name, world)
      end
    end
  end

  def send_reallocate_message(job_ids, allocated_user_name)
    job_ids = job_ids.split(',')
    job_ids.each do |job_id|
      send_update_job_header_request_message(job_id, allocated_user_name)
    end
  end

  private

  def default_survey_variables(job_id, user_name, world)
    { job_id: job_id,
      address: select_random_address,
      tla: nil,
      due_date: DUE_DATE,
      work_type: nil,
      user_name: user_name,
      world: world }
  end

  def load_address_files
    @north_addresses = JSON.parse(File.read(File.join(__dir__, '../data/addresses_north.json')))
    @east_addresses  = JSON.parse(File.read(File.join(__dir__, '../data/addresses_east.json')))
    @south_addresses = JSON.parse(File.read(File.join(__dir__, '../data/addresses_south.json')))
    @west_addresses  = JSON.parse(File.read(File.join(__dir__, '../data/addresses_west.json')))
  end

  def select_random_address
    # Select a random address from the addresses instance variable for the chosen location.
    instance_variable_get("@#{@location}_addresses")['addresses'][rand(1..LAST_ADDRESS)]
  end

  def send_ccs_create_message(job_id, user_name, world)
    variables = default_survey_variables(job_id, user_name, world).merge(
      tla: 'CCS', work_type: 'CCS'
    )

    send_create_job_request_message(job_id, variables)
  end

  def send_gff_create_message(job_id, user_name, world)
    variables = default_survey_variables(job_id, user_name, world).merge(
      tla: 'SLC', work_type: 'SS'
    )

    send_create_job_request_message(job_id, variables)
  end

  def send_hh_create_message(job_id, user_name, world)
    variables = default_survey_variables(job_id, user_name, world).merge(
      tla: 'Census', work_type: 'HH'
    )

    send_create_job_request_message(job_id, variables)
  end

  def send_lfs_create_message(job_id, user_name, world)
    variables = default_survey_variables(job_id, user_name, world).merge(
      tla: 'LFS', work_type: 'SS'
    )

    send_create_job_request_message(job_id, variables)
  end

  def send_create_job_request_message(job_id, variables)
    message = ERB.new(File.read(CREATE_MESSAGE_TEMPLATE), 0, '>').result(OpenStruct.new(variables).instance_eval { binding })
    VisitJob.perform_async(@server, @user_name, @password, job_id, message)
  end

  def send_update_job_header_request_message(job_id, allocated_user_name)
    variables = { job_id: job_id, allocated_user_name: allocated_user_name }
    message = ERB.new(File.read(UPDATE_MESSAGE_TEMPLATE), 0, '>').result(OpenStruct.new(variables).instance_eval { binding })
    UpdateJob.perform_async(@server, @user_name, @password, job_id, message)
  end
end
