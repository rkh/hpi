require 'hpi'
require 'rack/builder'

module HPI
  class Scenario
    attr_reader :name, :root

    def initialize(name)
      @root = File.expand_path("scenarios/#{name}", HPI.root)
      @name = name
    end

    def source_dir(&block)
      dir = File.expand_path('src', root)
      block ? Dir.chdir(&block) : dir
    end

    def rack_app
      return unless File.exist? 'config.ru'
      Rack::Builder.parse_file('config.ru').first
    end

    def step_file
      File.expand_path('steps', root)
    end

    def step_file?
      File.exist? step_file
    end

    def sinatra_app
      ruby_files = Dir["#{source_dir}/*.rb"]
      if ruby_files.size == 1
        load ruby_files.first
        Sinatra::Application
      end
    end

    def app
      source_dir { rack_app || sinatra_app }
    end

    alias to_s name
  end
end
