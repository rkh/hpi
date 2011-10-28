require 'hpi'
require 'set'

module HPI
  class Middleware
    include HPI::Lock

    def initialize(app)
      @app        = app
      @last_entry = nil
      @last_time  = Time.at(0)
      @bursts     = Hash.new { |h,k| h[k] = Set.new }
    end

    def call(env)
      case env['HTTP_X_HPI']
      when nil, ''  then synchronize { record(env) }
      when 'status' then synchronize { status(env) }
      end or @app.call(env)
    end

    def path(env)
      path = env["SCRIPT_NAME"].to_s + env["PATH_INFO"].to_s
      path << "?" << path["QUERY_STRING"] if path["QUERY_STRING"] and not path["QUERY_STRING"].empty?
      path
    end

    def record(env)
      return unless env['REQUEST_METHOD'] == 'GET'

      synchronize do
        @last_time + 1 >= Time.now ?
          @bursts[@last_entry] << path(env) :
          @last_entry = path(env)
        result = @app.call(env)
        @last_time = Time.now
        result
      end
    end

    def status(env)
      status = synchronize do
        info = SystemInfo.to_hash.merge 'bursts' => @bursts, 'server' => env['SERVER_SOFTWARE'], 'path' => path(env)
        OkJson.encode("system" => SystemInfo.to_hash, "rack" => info(env), "bursts" => @bursts)
      end

      [ 200, { 'Content-Type' => 'application/json', 'Content-Length' => status.bytesize }, status ]
    end
  end
end
