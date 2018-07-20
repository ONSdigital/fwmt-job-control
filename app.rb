# frozen_string_literal: true

require 'sinatra'
require 'sinatra/formkeeper'
require 'sinatra/flash'
require 'securerandom'

require_relative 'lib/job_request'

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
  erb :index, locals: { title: 'Create Job' }
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
    output = erb :index, locals: { title: 'Create Job' }
    fill_in_form(output)
  else
    message_template = File.join(__dir__, 'views/create_job_request.xml.erb')
    job_request = JobRequest.new(params, message_template)
    status_code = job_request.send_create_message
    flash[:notice] = "Successfully submitted #{job_count} jobs to Totalmobile."
    erb :index, locals: { title: 'Create Job' }
  end
end
