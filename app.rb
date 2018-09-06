# frozen_string_literal: true

require 'sucker_punch' # Must be required before sinatra.
require 'sinatra'
require 'sinatra/formkeeper'
require 'sinatra/flash'
require 'securerandom'
require 'user_agent_parser'
require 'bunny'

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

  def parse_user_agent
    UserAgentParser.parse(request.env['HTTP_USER_AGENT'])
  end
end

before do
  headers 'Content-Type' => 'text/html; charset=utf-8'
  @fwmt_development_url   = settings.fwmt_development_url
  @fwmt_preproduction_url = settings.fwmt_preproduction_url
  @fwmt_production_url    = settings.fwmt_production_url
end

get '/' do
  redirect '/tm/'
end

get '/tm/?' do
  erb :index, locals: { title: 'Create Job', category: 'TM' }
end

post '/tm/' do
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
    output = erb :index, locals: { title: 'Create Job', category: 'TM' }
    fill_in_form(output)
  else
    job_request = JobRequest.new(form[:server], form[:user_name], form[:password])
    job_request.send_create_message(form)
    flash[:notice] = 'Submitted jobs to Totalmobile. Check the logs for returned message IDs or failure status.'
    redirect '/'
  end
end

# Just in case anybody tries it.
get '/tm/create/?' do
  redirect '/'
end

get '/tm/delete/?' do
  erb :delete, locals: { title: 'Delete Jobs', category: 'TM' }
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
    output = erb :delete, locals: { title: 'Delete Jobs', category: 'TM' }
    fill_in_form(output)
  else
    job_request = JobRequest.new(form[:server], form[:user_name], form[:password])
    job_request.send_delete_message(form[:job_ids])
    flash[:notice] = 'Submitted delete requests to Totalmobile. Check the logs for returned message IDs or failure status.'
    redirect '/delete'
  end
end

get '/tm/reallocate/?' do
  erb :reallocate, locals: { title: 'Reallocate Jobs', category: 'TM' }
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
    output = erb :reallocate, locals: { title: 'Reallocate Jobs', category: 'TM' }
    fill_in_form(output)
  else
    job_request = JobRequest.new(form[:server], form[:user_name], form[:password])
    job_request.send_reallocate_message(form[:job_ids], form[:allocated_user_name])
    flash[:notice] = 'Submitted reallocate requests to Totalmobile. Check the logs for returned message IDs or failure status.'
    redirect '/reallocate'
  end
end

get '/rabbit/?' do
  
end

get '/rabbit/create/?' do
  erb :'rabbit/create', locals: { title: 'Create Jobs', category: 'Rabbit' }
end

post '/rabbit/create/' do
  
end

get '/rabbit/cancel/?' do
  erb :'rabbit_cancel', locals: { title: 'Cancel Jobs', category: 'Rabbit' }
end

post '/rabbit/cancel/' do
  
end

get '/rabbit/update/?' do
  erb :'rabbit_update', locals: { title: 'Update Jobs', category: 'Rabbit' }
end

post '/rabbit/update/' do

end


error 404 do
  erb :error, locals: { title: 'Error 404', user_agent: parse_user_agent }
end

error 500 do
  erb :error, locals: { title: 'Error 500', user_agent: parse_user_agent }
end
