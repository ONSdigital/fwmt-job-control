# frozen_string_literal: true

require 'sucker_punch' # Must be required before sinatra.
require 'sinatra'
require 'sinatra/formkeeper'
require 'sinatra/flash'
require 'sinatra/content_for'
require 'securerandom'
require 'user_agent_parser'
require 'csv'
require 'time'
require 'json'

require_relative 'lib/cf_env_parser'

require_relative 'lib/address_data'

require_relative 'lib/widgets'

require_relative 'lib/rabbit_create_generator'

require_relative 'lib/job_request'
require_relative 'lib/rabbit_handler'

# TM Endpoints
set :fwmt_development_url,   ENV['FWMT_DEVELOPMENT_URL']
set :fwmt_preproduction_url, ENV['FWMT_PREPRODUCTION_URL']
set :fwmt_production_url,    ENV['FWMT_PRODUCTION_URL']
set :fwmt_censustest_url,    ENV['FWMT_CENSUSTEST_URL']

# Admin Login
set :fwmt_admin_username,    ENV['FWMT_ADMIN_USERNAME']
set :fwmt_admin_password,    ENV['FWMT_ADMIN_PASSWORD']

# CloudFoundry Settings
cf_application = CfEnvParser.parse_application
if cf_application != nil
  set :fwmt_cf_enabled, true
  set :fwmt_cf_env_name, cf_application[:space]

  set :fwmt_cf_tm_url,      ENV['FWMT_TM_URL']
  set :fwmt_cf_tm_username, ENV['FWMT_TM_USERNAME']
  set :fwmt_cf_tm_password, ENV['FWMT_TM_PASSWORD']

  cf_services = CfEnvParser.parse_services
  set :fwmt_cf_rabbit_url,      cf_services[:rabbit_url]
  set :fwmt_cf_rabbit_username, cf_services[:rabbit_username]
  set :fwmt_cf_rabbit_password, cf_services[:rabbit_password]
  set :fwmt_cf_rabbit_vhost,    cf_services[:rabbit_vhost]
else
  set :fwmt_cf_enabled, false
end

enable :sessions

if settings.fwmt_admin_username != nil and settings.fwmt_admin_password != nil
  use Rack::Auth::Basic, "Requires Authentication" do |username, password|
    [username, password] == [settings.fwmt_admin_username, settings.fwmt_admin_password]
  end
end

helpers do
  def preset_address_lists
    AddressData.get_data_files
  end

  # View helper for escaping HTML output.
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def parse_user_agent
    UserAgentParser.parse(request.env['HTTP_USER_AGENT'])
  end
end

helpers Sinatra::ContentFor

before do
  headers 'Content-Type' => 'text/html; charset=utf-8'
  @fwmt_development_url   = settings.fwmt_development_url
  @fwmt_preproduction_url = settings.fwmt_preproduction_url
  @fwmt_production_url    = settings.fwmt_production_url
  @fwmt_censustest_url    = settings.fwmt_censustest_url
end

get '/' do
  redirect '/tm/create'
end

get '/tm/?' do
  redirect '/tm/create'
end

get '/tm/create/?' do
  erb :'tm/create'
end

post '/tm/create' do
  form do
    filters :strip
    field :server,     present: false
    field :user_name,  present: false
    field :password,   present: false
    field :survey,     present: true
    field :world,      present: true
    field :user_names, present: false
    field :skills,     default: 'Survey'
    field :job_count,  present: true, int: { between: 1..100 }
    field :location,   present: true
  end

  if form.failed?
    output = erb :'tm/create'
    fill_in_form(output)
  else
    if settings.fwmt_cf_enabled
      job_request = JobRequest.new(settings.fwmt_cf_tm_url,
                                   settings.fwmt_cf_tm_username,
                                   settings.fwmt_cf_tm_password)
    else
      job_request = JobRequest.new(form[:server], form[:user_name], form[:password])
    end
    job_request.send_create_message(form)
    flash[:notice] = 'Submitted jobs to Totalmobile. Check the logs for returned message IDs or failure status.'
    redirect '/tm/create'
  end
end

get '/tm/delete/?' do
  erb :'tm/delete'
end

post '/tm/delete' do
  form do
    filters :strip
    field :server,    present: false
    field :user_name, present: false
    field :password,  present: false
    field :job_ids,   present: true
  end

  if form.failed?
    p form
    output = erb :'tm/delete'
    fill_in_form(output)
  else
    if settings.fwmt_cf_enabled
      job_request = JobRequest.new(settings.fwmt_cf_tm_url,
                                   settings.fwmt_cf_tm_username,
                                   settings.fwmt_cf_tm_password)
    else
      job_request = JobRequest.new(form[:server], form[:user_name], form[:password])
    end
    job_request.send_delete_message(form[:job_ids])
    flash[:notice] = 'Submitted delete requests to Totalmobile. Check the logs for returned message IDs or failure status.'
    redirect '/delete'
  end
end

get '/tm/reallocate/?' do
  erb :'tm/reallocate'
end

post '/tm/reallocate' do
  form do
    filters :strip
    field :server,              present: true
    field :user_name,           present: true
    field :password,            present: true
    field :job_ids,             present: true
    field :allocated_user_name, present: true
  end

  if form.failed?
    output = erb :'tm/reallocate'
    fill_in_form(output)
  else
    if settings.fwmt_cf_enabled
      job_request = JobRequest.new(settings.fwmt_cf_tm_url,
                                   settings.fwmt_cf_tm_username,
                                   settings.fwmt_cf_tm_password)
    else
      job_request = JobRequest.new(form[:server], form[:user_name], form[:password])
    end
    job_request.send_reallocate_message(form[:job_ids], form[:allocated_user_name])
    flash[:notice] = 'Submitted reallocate requests to Totalmobile. Check the logs for returned message IDs or failure status.'
    redirect '/reallocate'
  end
end

get '/rabbit/?' do
  redirect '/rabbit/create'
end

get '/rabbit/create/?' do
  erb :'rabbit/create'
end

post '/rabbit/create' do
  form do
    TMServer.form_config self

    TMWorld.form_config self

    ResnoGenerator.form_config self

    IDGenerator.form_config self

    SurveyType.form_config self

    DateGenerator.form_config self

    AddressGenerator.form_config self

    ContactGenerator.form_config self

    AddProps.form_config self

    field :count, uint: true

    field :send, present: false
    field :view, present: false
  end

  if form.failed?
    p form
    flash.now[:error] = 'Error in form'
    output = erb :'rabbit/create'
    fill_in_form(output)
  else
    if settings.fwmt_cf_enabled
      handler = RabbitHandler.new(settings.fwmt_cf_rabbit_url,
                                  settings.fwmt_cf_rabbit_username,
                                  settings.fwmt_cf_rabbit_password,
                                  settings.fwmt_cf_rabbit_vhost)
    else
      vhost = form[:rabbit_vhost]
      if not vhost.nil?
        vhost = vhost.length == 0 ? nil : vhost
      end
      handler = RabbitHandler.new(form[:rabbit_server], form[:rabbit_username], form[:rabbit_password], vhost)
    end
    result = handler.run(form)
    handler.close
    flash[:notice] = 'All jobs sent to Rabbit'
    flash[:jobs] = result
    redirect '/rabbit/create' if form[:send]
    redirect '/rabbit/show' if form[:view]
  end
end

get '/rabbit/show' do
  erb :'rabbit/show'
end

get '/rabbit/cancel/?' do
  erb :'rabbit/cancel'
end

post '/rabbit/cancel' do
  
end

get '/rabbit/update/?' do
  erb :'rabbit/update'
end

post '/rabbit/update' do
  form do
    filters :strip
  end

  if form.failed?
    output = erb :'rabbit/update'
    fill_in_form(output)
  else
    job_request = JobRequest.new(form[:server], form[:user_name], form[:password])
    job_request.send_reallocate_message(form[:job_ids], form[:allocated_user_name])
    flash[:notice] = 'Submitted reallocate requests to Totalmobile. Check the logs for returned message IDs or failure status.'
    redirect '/reallocate'
  end
end

error 404 do
  erb :error, locals: { title: 'Error 404', user_agent: parse_user_agent }
end

error 500 do
  erb :error, locals: { title: 'Error 500', user_agent: parse_user_agent }
end
