require 'backports'
ENV['RACK_ENV'] = 'production'

module HPI
  autoload :Benchmark,  'hpi/benchmark'
  autoload :CLI,        'hpi/cli'
  autoload :HTTPerf,    'hpi/httperf'
  autoload :Middleware, 'hpi/middleware'
  autoload :Scenario,   'hpi/scenario'
  autoload :Server,     'hpi/server'

  class << self
    attr_accessor :root
  end
end
