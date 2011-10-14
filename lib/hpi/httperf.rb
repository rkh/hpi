require 'hpi'
require 'set'

module HPI
  class HTTPerf
    OPTIONS  ||= {}
    DEFAULTS ||= {}

    def self.add_option(option, argument = option.to_s.tr('_', '-'), default = nil)
      attr_accessor option
      define_method("#{option}!") { public_send("#{option}=", true) }
      define_method("#{option}?") { !!public_send(option) }
      OPTIONS[option], DEFAULTS[option] = argument, default
    end

    add_option :burst_length
    add_option :calls,            "num-calls"
    add_option :client
    add_option :close_with_reset
    add_option :connections,      "num-conns"
    add_option :debug_level
    add_option :hog_ports,        "hog",              true
    add_option :host,             "server"
    add_option :host_name,        "server-name"
    add_option :http_version,     "http-version",     "1.1"
    add_option :max_connections
    add_option :max_piped_calls
    add_option :no_host_header,   "no-host-hdr"
    add_option :period
    add_option :port
    add_option :print_reply
    add_option :print_request
    add_option :rate
    add_option :response_buffer,  "recv-buffer"
    add_option :retry_on_failure
    add_option :request_buffer,   "send-buffer"
    add_option :request_method,   "method",           "GET"
    add_option :session_cookie
    add_option :ssl
    add_option :ssl_ciphers
    add_option :ssl_no_reuse
    add_option :think_timeout
    add_option :timeout
    add_option :uri
    add_option :verbose
    add_option :wlog
    add_option :wsess
    add_option :wsesslog

    attr_reader :headers, :failure_codes
    attr_accessor :httperf

    def initialize(host, port)
      DEFAULTS.each { |k, v| public_send("#{k}=", v) }
      @host, @port   = host, port
      @headers       = {}
      @failure_codes = []
      @httperf       = `which httperf`.chop
    end

    def command
      fail "httperf not found" unless File.executable? httperf
      OPTIONS.inject(httperf) do |cmd, (option, key)|
        case value = public_send(option)
        when nil, false then cmd
        when true       then "#{cmd} --#{key}"
        else "#{cmd} --#{key}=#{value.inspect}"
        end
      end
    end

    def session(sessions, calls, think_time)
      self.wsess = [sessions, calls, think_time].join(",")
    end

    def session_file(step_file, sessions, think_time)
      self.wsesslog = [sessions, think_time, step_file].join(",")
    end

    def run
      `#{command} 2>&1`[/^Request rate.*/]
    end

    def debug?
      debug_level? and debug_level > 0
    end
  end
end
