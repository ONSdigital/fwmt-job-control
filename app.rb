# frozen_string_literal: true

require 'sucker_punch' # Must be required before sinatra.
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
    job_request.send_create_message
    flash[:notice] = 'Submitted jobs to Totalmobile. Check the logs for returned message IDs or failure status.'
    redirect '/'
  end
end
