require 'hpi'

module HPI
  module Lock
    module Rubinius
      def lock(&block)
        ::Rubinius.lock(self, &block)
      end
    end

    module Ruby
      def lock(&block)
        global_lock { @lock = Mutex.new unless lock? } unless lock?
        @lock.synchronize(&block)
      end

      private

      def lock?
        instance_variable_defined? :@lock
      end
    end

    extend self

    def global_lock(&block)
      HPI::Lock.lock(&block)
    end

    if defined? ::Rubinius
      include Rubinius
    else
      include Ruby
      require 'thread'
      @lock = Mutex.new
    end
  end
end
