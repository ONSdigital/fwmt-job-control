# frozen_string_literal: true

equire_relative 'app.rb'

use Rack::ETag
use Rack::ConditionalGet
use Rack::Deflater

run Sinatra::Application
