require 'hpi'

module HPI
  # This middleware is used to check if the server is running.
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      if env['PATH_INFO'] == '/__hpi__'
        [200, {'Content-Type' => 'text/plain'}, ['ok']]
      else
        @app.call(env)
      end
    end
  end
end
