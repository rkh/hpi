require 'hpi'
require 'pstore'
require 'forwardable'

module HPI
  class Store
    extend SingleForwardable, Tool::Lock
    def_singleton_delegators :store, :[], :[]=, :abort, :commit, :delete, :fetch

    # avoid warnings
    @store = @file = @transaction = false

    def self.store
      @store ||= PStore.new(file)
    end

    def self.file
      @file ||= File.expand_path('.hpi.store', ENV['HOME'])
    end

    def self.file=(value)
      @store, @file = nil, value
    end

    def self.transaction(&block)
      # PStore in 1.8 does not support thread-safe mode
      return yield if transaction?
      synchronize do
        begin
          @transaction = true
          store.transaction(&block)
        ensure
          @transaction = false
        end
      end
    end

    def self.transaction?
      @transaction
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      Store.transaction { @app.call(env) }
    end
  end
end
