$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'hpi/version'

desc 'build gem'
task :build => 'build:all'
namespace :build do
  task(:full) { sh "middleware_only=0 gem build hpi.gemspec" }
  task(:rack) { sh "middleware_only=1 gem build hpi.gemspec" }
  task :all => [:full, :rack]
end

desc 'install gem'
task :install => 'install:all'
namespace :install do
  task(:full => 'build:full') { sh "gem install hpi-#{HPI::VERSION}.gem" }
  task(:rack => 'build:rack') { sh "gem install hpi-middleware-#{HPI::VERSION}.gem" }
  task(:all => [:full, :rack])
end

desc 'run specs'
task(:spec) { sh 'rspec spec' }

task :test    => :spec
task :default => [:spec, :build]
