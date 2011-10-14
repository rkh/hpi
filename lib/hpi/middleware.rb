require 'hpi'

module HPI
  # This middleware is used to check if the server is running.
  class Middleware
    @@null    = File.open('/dev/null', 'w')
    @@counter = 0

    def initialize(app)
      @app = app
    end

    def call(env)
      env['rack.errors'] = @@null
      if env['PATH_INFO'] == '/__hpi__'
        [200, {'Content-Type' => 'text/plain'}, ['ok']]
      else
        @@counter = (@@counter + 1) % 50
        $stderr.print('.') if @@counter == 0
        @app.call(env)
      end
    end
  end
end
