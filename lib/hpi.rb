require 'backports'
require 'tool'

module HPI
  autoload :HTTPerf,      'hpi/httperf'
  autoload :Middleware,   'hpi/middleware'
  autoload :OkJson,       'hpi/ok_json'
  autoload :Result,       'hpi/result'
  autoload :Scenario,     'hpi/scenario'
  autoload :Store,        'hpi/store'
  autoload :SystemInfo,   'hpi/system_info'
  autoload :VERSION,      'hpi/version'
  autoload :WebInterface, 'hpi/web_interface'
end
