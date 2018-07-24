# frozen_string_literal: true

require 'sinatra'
require 'sinatra/formkeeper'
require 'sinatra/flash'
require 'securerandom'

require_relative 'lib/job_request'

set :fwmt_development_url,   ENV['FWMT_DEVELOPMENT_URL']
set :fwmt_preproduction_url, ENV['FWMT_PREPRODUCTION_URL']
set :fwmt_production_url,    ENV['FWMT_PRODUCTION_URL']

enable :sessions

helpers do
  # View helper for escaping HTML output.
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def build_success_flash(message_ids)
    flash_message = []
    flash_message << 'Successfully submitted 1 job with the following message ID to Totalmobile:<br>' if message_ids.size == 1
    flash_message << "Successfully submitted #{message_ids.size} jobs with the following message IDs to Totalmobile:<br>" if message_ids.size > 1
    message_ids.each { |message_id| flash_message << "<span class=\"message-id\">#{message_id}</span><br>" }
    flash_message.join
  end
end

before do
  headers 'Content-Type' => 'text/html; charset=utf-8'
end

get '/?' do
  erb :index, locals: { title: 'Create Job',
                        fwmt_development_url: settings.fwmt_development_url,
                        fwmt_preproduction_url: settings.fwmt_preproduction_url,
                        fwmt_production_url: settings.fwmt_production_url }
end

post '/' do
  form do
    field :server,     present: true
    field :user_name,  present: true
    field :password,   present: true
    field :survey,     present: true
    field :world,      present: true
    field :user_names, present: true
    field :job_count,  present: true, int: { between: 1..100 }
    field :location,   present: true
  end

  if form.failed?
    output = erb :index, locals: { title: 'Create Job',
                                   fwmt_development_url: settings.fwmt_development_url,
                                   fwmt_preproduction_url: settings.fwmt_preproduction_url,
                                   fwmt_production_url: settings.fwmt_production_url }
    fill_in_form(output)
  else
    job_request = JobRequest.new(params)
    begin
      message_ids = job_request.send_create_message
      flash[:notice] = build_success_flash(message_ids)
      redirect '/'
    rescue RestClient::Unauthorized
      flash[:error] = 'Invalid Totalmobile server credentials'
      redirect '/'
    end
  end
end
