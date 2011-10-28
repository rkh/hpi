require 'hpi'
require 'sinatra/base'
require 'slim'
require 'compass'

module HPI
  class WebInterface < Sinatra::Base
    configure do
      enable :sessions, :lock, :show_exceptions
      disable :protection, :threaded

      set :port,   Integer(ENV["PORT"] || 5678)
      set :bind,   '127.0.0.1'
      set :server, %w[puma thin mongrel]
      set :views,  File.expand_path('web_interface', root)
      set :slim,   :pretty => true
    end

    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader
    end

    get('/') { slim :index }
  end
end
