require 'hpi'
require 'rack/handler'
require 'open-uri'

module HPI
  class Server
    def self.new(name = nil)
      return super unless self == Server
      servers.fetch(name.to_s).new(name)
    rescue IndexError
      raise ArgumentError, "unkown server #{name}"
    end

    def self.handles(*servers)
      servers.each { |name| Server.servers[name.to_s] = self }
    end

    def self.servers
      @servers ||= {}
    end

    attr_reader :app, :port, :host, :name, :server

    def run(app, port)
      @port, @host = port, '127.0.0.1'
      @app         = Middleware.new(app)
      run!
      sleep(0.01) until running?
    end

    def running?
      open("http://#{host}:#{port}/__hpi__").read == 'ok'
    rescue Errno::ECONNREFUSED, OpenURI::HTTPError
      false
    end

    def stop
      stop! unless server
      @server = nil
    end

    alias to_s name

    private

    def initialize(name)
      @name = name.to_s
    end

    def stop!
      server.stop
    end

    def run!
      raise NotImplementedError, 'subclass responsiblity'
    end

    class BlockingRack < Server
      handles :webrick, :thin

      def initialize(name)
        @handler = ::Rack::Handler.get(name)
        @server  = nil
        super
      end

      def run!
        options = {:Host => host, :Port => port}
        Thread.new do
          @handler.run(app, options) do |server|
            server.silent = true if server.respond_to? :silent=
            @server = server
          end
        end
      end
    end

    class Mongrel < Server
      handles :mongrel

      def run!
        @server = ::Mongrel::HttpServer.new(host, post)
        server.register '/', ::Rack::Handler::Mongrel.new(app)
        server.run
      end
    end

    class Puma < Server
      handles :puma

      def run!
        @server = ::Puma::Server.new(app)
        server.add_tcp_listener(host, ports)
        server.run
      end

      def stop
        server.stop(true)
      end
    end

    class UnicornAndFriend < Server
      handles :unicorn, :rainbows, :zbatery

      def setup
        const_name = name.capitalize
        require name unless Object.const_defined? const_name
        Object.const_get(const_name)
      end

      def run!
        handler = setup::HttpServer
        @server = handler.new(app, :listeners => ["#{host}:#{port}"])
        server.start
      end
    end
  end
end
