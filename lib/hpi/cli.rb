require 'hpi'

module HPI
  class CLI
    attr_accessor :stdout, :stderr, :args, :method

    def self.run(args = ARGV, stdout = $stdout, stderr = $stderr)
      cli        = new
      cli.stdout = stdout
      cli.stderr = stderr
      method     = args.shift
      unless CLI.supports? method
        stderr.puts "unkown command #{method}", "" if method
        method = :help
      end
      cli.send(method, *args)
    end

    def self.supports?(command)
      instance_methods(false).any? do |method|
        method.to_s == command.to_s
      end
    end

    def run(server, scenario)
      Thread.abort_on_exception = true
      benchmark        = Benchmark.new(server, scenario)
      benchmark.stdout = stdout
      benchmark.stderr = stderr
      benchmark.run
    end

    def list
      stdout.puts "Servers: " << HPI::Server.servers.keys.join(', ')
    end

    def help
      stderr.puts <<-HELP.gsub(/^ */, '')
        Usage: #$0 COMMAND [ARGS..]
        
        Available Commands:
        run SERVER SCENARIO\tbenchmarks given scenario on given server
        list\t\t\tlists known scenarios and servers
        help\t\t\tdisplays this help text
      HELP
    end
  end
end
