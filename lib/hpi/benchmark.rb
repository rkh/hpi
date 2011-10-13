require 'hpi'
require 'socket'

module HPI
  class Benchmark
    attr_accessor :server, :scenario, :stdout, :stderr

    def initialize(server, scenario)
      @server   = Server.new(server)
      @scenario = Scenario.new(scenario)
      @stdout   = $stdout
      @stderr   = $stderr
    end

    def port
      @port ||= ENV['PORT'] || find_port
    end

    def find_port
      (49152..65535).detect do |port|
        begin
          TCPSocket.open('127.0.0.1', port).close
          true
        rescue Errno::ECONNREFUSED, IOError
          false
        end
      end
    end

    def run
      scenario.source_dir do
        err ">> Starting %s on port %d running %s", server, port, scenario
        server.run(scenario.app, port)

        err ">> Server running, benchmarking sessions"
        httperf    = HTTPerf.new("127.0.0.1", port)

        # unhardcode
        sessions   = 20
        calls      = 4
        think_time = 0
        httperf.burst_length = 5
        httperf.connections  = 20
        httperf.calls        = 20

        if scenario.step_file?
          httperf.session_file(scenario.step_file, sessions, think_time)
        else
          httperf.session(sessions, calls, think_time)
        end

        httperf.run
        server.stop
      end
    end

    private

    def out(str, *args)
      stdout.puts(str % args)
    end

    def err(str, *args)
      stderr.puts(str % args)
    end
  end
end
