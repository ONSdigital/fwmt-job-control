# frozen_string_literal: true

require 'sucker_punch' # Must be required before sinatra.
require 'sinatra'
require 'sinatra/formkeeper'
require 'sinatra/flash'
require 'sinatra/content_for'
require 'securerandom'
require 'user_agent_parser'

require_relative 'lib/address_data'

require_relative 'lib/date_generator'
require_relative 'lib/address_generator'
require_relative 'lib/id_generator'
require_relative 'lib/resno_generator'

require_relative 'lib/rabbit_create_generator'

require_relative 'lib/job_request'
require_relative 'lib/rabbit_handler'

set :fwmt_development_url,   ENV['FWMT_DEVELOPMENT_URL']
set :fwmt_preproduction_url, ENV['FWMT_PREPRODUCTION_URL']
set :fwmt_production_url,    ENV['FWMT_PRODUCTION_URL']
set :fwmt_censustest_url,    ENV['FWMT_CENSUSTEST_URL']

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
    filters :strip

    field :server, present: true
    field :username, present: true
    field :password, present: true

    field :idKind, present: true, regexp: %r{^(single|list|incr|rand)$}
    field :id,          present: false # use one ID (single job only)
    field :idList,      present: false # provide a list of IDs
    field :idIncrStart, present: false # pick IDs above the start
    # or, randomly generate IDs

    field :surveyType, present: true, regexp: %r{^(CCS|HH|GFF|LFS|OHS)$}

    field :resNoKind, present: true, regexp: %r{^(single|list)$}
    field :resNo,     present: false # use one resource number
    field :resNoList, present: false # split jobs between a list of resource numbers

    field :dueDateKind,  present: true, regexp: %r{^(set|hours|days)$}
    field :dueDate,      present: false
    field :dueDateHours, present: false
    field :dueDateDays,  present: false

    field :addrKind, present: true, regexp: %r{^(single|preset_list|list)$}
    field :addrStrategy, present: false, regexp: %r{^(random|incremental|once_per)$}
    field :addr,         present: false
    field :addrList,     present: false
    field :addrRandList, present: false

    field :additionalProperties, present: false

    field :count, uint: true
  end

  if form.failed?
    p "Fail!"
    p form
    output = erb :'rabbit/create'
    fill_in_form(output)
  else
    handler = RabbitHandler.new(form[:server], form[:username], form[:password])
    handler.run(form)
    handler.close
    flash[:notice] = 'All jobs sent to Rabbit'
    redirect '/rabbit/create'
  end
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
