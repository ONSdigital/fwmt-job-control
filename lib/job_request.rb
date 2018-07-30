# frozen_string_literal: true

require 'time'
require 'json'

require_relative 'visit_job'

# Class encapsulating a job SOAP request.
class JobRequest
  CREATE_MESSAGE_TEMPLATE = File.join(__dir__, '../views/create_job_request.xml.erb')
  DUE_DATE = (Time.now.to_date >> 1).to_time.iso8601 # One month from now
  LAST_ADDRESS = 100

  def initialize(params)
    @server     = params['server']
    @user_name  = params['user_name']
    @password   = params['password']
    @survey     = params['survey'].downcase
    @world      = params['world']
    @user_names = params['user_names']
    @job_count  = params['job_count'].to_i
    @location   = params['location']
    load_address_files
  end

  def send_create_message
    user_names = @user_names.split(',')
    user_names.each do |user_name|
      1.upto(@job_count) do
        job_id = SecureRandom.hex(4)

        # Dynamically dispatch to the private method for the survey.
        method_name = "send_#{@survey}_create_message"
        send(method_name, job_id, user_name)
      end
    end
  end

  private

  def default_survey_variables(job_id, user_name)
    { job_id: job_id,
      address: select_random_address,
      tla: nil,
      due_date: DUE_DATE,
      work_type: nil,
      user_name: user_name,
      world: @world }
  end

  def load_address_files
    @north_addresses = JSON.parse(File.read(File.join(__dir__, '../data/addresses_north.json')))
    @east_addresses = JSON.parse(File.read(File.join(__dir__, '../data/addresses_east.json')))
    @south_addresses = JSON.parse(File.read(File.join(__dir__, '../data/addresses_south.json')))
    @west_addresses = JSON.parse(File.read(File.join(__dir__, '../data/addresses_west.json')))
  end

  def select_random_address
    # Select a random address from the addresses instance variable for the chosen location.
    instance_variable_get("@#{@location}_addresses")['addresses'][rand(1..LAST_ADDRESS)]
  end

  def send_ccs_create_message(job_id, user_name)
    variables = default_survey_variables(job_id, user_name).merge(
      tla: 'CCS', work_type: 'CCS'
    )

    send_create_job_request_message(job_id, variables)
  end

  def send_gff_create_message(job_id, user_name)
    variables = default_survey_variables(job_id, user_name).merge(
      tla: 'SLC', work_type: 'SS'
    )

    send_create_job_request_message(job_id, variables)
  end

  def send_hh_create_message(job_id, user_name)
    variables = default_survey_variables(job_id, user_name).merge(
      tla: 'Census', work_type: 'HH'
    )

    send_create_job_request_message(job_id, variables)
  end

  def send_lfs_create_message(job_id, user_name)
    variables = default_survey_variables(job_id, user_name).merge(
      tla: 'LFS', work_type: 'SS'
    )

    send_create_job_request_message(job_id, variables)
  end

  def send_create_job_request_message(job_id, variables)
    message = ERB.new(File.read(CREATE_MESSAGE_TEMPLATE), 0, '>').result(OpenStruct.new(variables).instance_eval { binding })
    VisitJob.perform_async(@server, @user_name, @password, job_id, message)
  end
end
