$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'hpi/version'

middleware_only = ENV['middleware_only'].to_i != 0
name = middleware_only ? 'hpi-middleware' : 'hpi'

Gem::Specification.new name, HPI::VERSION do |s|
  s.description = "A tool to benchmark an HTTP server under realistic load."
  s.summary     = "HTTP Performance Investigation"
  s.authors     = ["Konstantin Haase"]
  s.email       = "konstantin.mailinglists@googlemail.com"
  s.homepage    = "http://github.com/rkh/hpi"
  s.files       = `git ls-files`.split("\n") - %w[Gemfile .gitignore .travis.yml]

  s.add_dependency 'backports'
  s.add_dependency 'tool'

  if middleware_only
    s.summary << " (middleware only)"
  else
    s.test_files  = s.files.select { |p| p =~ /^spec\/.*_spec.rb/ }
    s.executables = ['hpi']

    s.add_dependency 'sinatra', '~> 1.3'
    s.add_dependency 'sinatra-contrib'
    s.add_dependency 'thin'
    s.add_dependency 'slim'
    s.add_dependency 'compass'

    s.add_development_dependency 'rspec', '~> 2.7'
  end
end
