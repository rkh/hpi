require 'sinatra'
use Rack::Lint

get '/' do
  "Hello World"
end
