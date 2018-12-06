# frozen_string_literal: true

require_relative 'visit_job'
require_relative 'update_job'
require_relative 'delete_job'

# Class encapsulating a job SOAP request.
class JobRequest
  CREATE_MESSAGE_TEMPLATE = File.join(__dir__, '../views/tm/create_job_request.xml.erb')
  DELETE_MESSAGE_TEMPLATE = File.join(__dir__, '../views/tm/delete_job_request.xml.erb')
  UPDATE_MESSAGE_TEMPLATE = File.join(__dir__, '../views/tm/update_job_header_request.xml.erb')
  DUE_DATE     = (Time.now.to_date >> 1).to_time.iso8601 # One month from now
  LAST_ADDRESS = 100 # There are up to one hundred test addresses per location

  def initialize(server, user_name, password)
    @server    = server
    @user_name = user_name
    @password  = password
  end

  def send_create_message(form)
    @location = form[:location]
    load_address_files

    mendel = form[:world] != "Default"

    user_names = form[:user_names].split(',')
    user_names.each do |user_name|
      1.upto(form[:job_count].to_i) { send_create_message_for_survey(form[:survey], user_name, form[:skills], form[:world], mendel) }
    end

    send_create_message_for_survey(form[:survey], nil, form[:skills], form[:world], mendel) if user_names.empty?
  end

  def send_create_message_for_survey(survey, user_name, skills, world, mendel)
    job_id = SecureRandom.hex(4)

    # Dynamically dispatch to the private create method for the survey.
    method_name = "send_#{survey.downcase}_create_message"
    send(method_name, job_id, user_name, skills, world, mendel)
  end

  def send_delete_message(job_ids)
    job_ids = job_ids.gsub('\n', '').split(',')
    p job_ids
    job_ids.each do |job_id|
      send_delete_job_request_message(job_id)
    end
  end

  def send_reallocate_message(job_ids, allocated_user_name)
    job_ids = job_ids.split(',')
    job_ids.each do |job_id|
      send_update_job_header_request_message(job_id, allocated_user_name)
    end
  end

  private

  def default_survey_variables(job_id, user_name, skills, world, mendel)
    { job_id: job_id,
      address: select_random_address,
      tla: nil,
      due_date: DUE_DATE,
      work_type: nil,
      user_name: user_name,
      skills: skills,
      world: world,
      mendel: mendel }
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

  def send_ccs_create_message(job_id, user_name, skills, world, mendel)
    variables = default_survey_variables(job_id, user_name, skills, world, mendel).merge(
      tla: 'CCS', work_type: 'CCS'
    )

    send_create_job_request_message(job_id, variables)
  end

  def send_gff_create_message(job_id, user_name, skills, world, mendel)
    variables = default_survey_variables(job_id, user_name, skills, world, mendel).merge(
      tla: 'SLC', work_type: 'SS'
    )

    send_create_job_request_message(job_id, variables)
  end

  def send_hh_create_message(job_id, user_name, skills, world, mendel)
    variables = default_survey_variables(job_id, user_name, skills, world, mendel).merge(
      tla: 'Census', work_type: 'HH'
    )

    send_create_job_request_message(job_id, variables)
  end

  def send_lfs_create_message(job_id, user_name, skills, world, mendel)
    variables = default_survey_variables(job_id, user_name, skills, world, mendel).merge(
      tla: 'LFS', work_type: 'SS'
    )

    send_create_job_request_message(job_id, variables)
  end

  def send_create_job_request_message(job_id, variables)
    message = ERB.new(File.read(CREATE_MESSAGE_TEMPLATE), 0, '>').result(OpenStruct.new(variables).instance_eval { binding })
    VisitJob.perform_async(@server, @user_name, @password, job_id, message)
  end

  def send_delete_job_request_message(job_id)
    variables = { job_id: job_id }
    message = ERB.new(File.read(DELETE_MESSAGE_TEMPLATE), 0, '>').result(OpenStruct.new(variables).instance_eval { binding })
    DeleteJob.perform_async(@server, @user_name, @password, job_id, message)
  end

  def send_update_job_header_request_message(job_id, allocated_user_name)
    variables = { job_id: job_id, allocated_user_name: allocated_user_name }
    message = ERB.new(File.read(UPDATE_MESSAGE_TEMPLATE), 0, '>').result(OpenStruct.new(variables).instance_eval { binding })
    UpdateJob.perform_async(@server, @user_name, @password, job_id, message)
  end
end
