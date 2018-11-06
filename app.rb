# frozen_string_literal: true

require 'sucker_punch' # Must be required before sinatra.
require 'sinatra'
require 'sinatra/formkeeper'
require 'sinatra/flash'
require 'sinatra/content_for'
require 'securerandom'
require 'user_agent_parser'
require 'csv'

require_relative 'lib/address_data'

require_relative 'lib/date_generator'
require_relative 'lib/address_generator'
require_relative 'lib/id_generator'
require_relative 'lib/resno_generator'

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

# Census Login
set :fwmt_census_username,   ENV['FWMT_CENSUS_USERNAME']
set :fwmt_census_password,   ENV['FWMT_CENSUS_PASSWORD']

# SSD Login
set :fwmt_ssd_username,      ENV['FWMT_SSD_USERNAME']
set :fwmt_ssd_password,      ENV['FWMT_SSD_PASSWORD']

# CloudFoundry Settings
set :fwmt_cf_enabled,        ENV['FWMT_CF_ENABLED']
set :fwmt_cf_env_name,       ENV['FWMT_CF_ENV_NAME']
set :fwmt_cf_env_tm_url,     ENV['FWMT_CF_ENV_TM_URL']
set :fwmt_cf_env_rabbit_url, ENV['FWMT_CF_ENV_RABBIT_URL']

enable :sessions

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
    field :server,     present: true
    field :user_name,  present: true
    field :password,   present: true
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
    job_request = JobRequest.new(form[:server], form[:user_name], form[:password])
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
    field :server,    present: true
    field :user_name, present: true
    field :password,  present: true
    field :job_ids,   present: true
  end

  if form.failed?
    output = erb :'tm/delete'
    fill_in_form(output)
  else
    job_request = JobRequest.new(form[:server], form[:user_name], form[:password])
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
    job_request = JobRequest.new(form[:server], form[:user_name], form[:password])
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
    field :server,   present: true,  filters: :strip
    field :username, present: true,  filters: :strip
    field :password, present: true,  filters: :strip
    field :vhost,    present: false, filters: :strip

    field :idKind, present: true, regexp: %r{^(single|list|incr|rand)$}
    field :id,          present: false, filters: :strip # use one ID (single job only)
    field :idList,      present: false, filters: :strip # provide a list of IDs
    field :idIncrStart, present: false, filters: :strip # pick IDs above the start
    # or, randomly generate IDs

    field :surveyType, present: true, regexp: %r{^(CCS|HH|GFF|LFS|OHS)$}, filters: :strip

    field :resNoKind, present: true, regexp: %r{^(single|list)$}, filters: :strip
    field :resNo,     present: false # use one resource number
    field :resNoList, present: false # split jobs between a list of resource numbers

    field :dueDateKind,  present: true, regexp: %r{^(set|hours|days)$}, filters: :strip
    field :dueDate,      present: false, filters: :strip
    field :dueDateHours, present: false, filters: :strip
    field :dueDateDays,  present: false, filters: :strip

    field :addrKind, present: true, regexp: %r{^(single|preset|list|file)$}, filters: :strip
    field :addrStrategy, present: false, regexp: %r{^(random|incremental|once_per)$}, filters: :strip
    field :addr,         present: false, filters: :strip
    field :addrPreset,   present: false, filters: :strip
    field :addrList,     present: false, filters: :strip
    field :addrFile,     present: false

    field :additionalProperties, present: false

    field :count, uint: true

    field :send, present: false
    field :view, present: false
  end

  if form.failed?
    p form
    output = erb :'rabbit/create'
    fill_in_form(output)
  else
    vhost = form[:vhost].length == 0 ? nil : form[:vhost]
    handler = RabbitHandler.new(form[:server], form[:username], form[:password], vhost)
    result = handler.run(form)
    handler.close
    flash[:notice] = 'All jobs sent to Rabbit'
    redirect '/rabbit/create' if form[:send]
    flash[:jobs] = result
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
