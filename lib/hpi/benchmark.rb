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
      Dir.chdir(scenario.source_dir) do
        err ">> Starting %s on port %d running %s", server, port, scenario
        server.run(scenario.app, port)
        err ">> Server running, benchmarking sessions"
        # replace with funky benchmarking
        system "autobench --host1 127.0.0.1 --uri1 / --low_rate 20 " \
          "--high_rate 200 --rate_step 20 --num_call 10 --num_conn " \
          "5000 --timeout 5 --file results.tsv"
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
