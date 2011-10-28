require 'hpi'

module HPI
  module SystemInfo
    extend self

    def cpu_count
      return Java::Java.lang.Runtime.getRuntime.availableProcessors if defined? Java::Java
      return File.read('/proc/cpuinfo').scan(/^processor\s*:/).size if File.exist? '/proc/cpuinfo'
      require 'win32ole'
      WIN32OLE.connect("winmgmts://").ExecQuery("select * from Win32_ComputerSystem").NumberOfProcessors
    rescue LoadError
      Integer `sysctl -n hw.ncpu 2>/dev/null` rescue 1
    end

    def implementation
      engine = defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'ruby'
      engine == 'ruby' ? 'mri' : engine
    end

    def ruby_version
      RUBY_VERSION
    end

    def implementation_version
      case ruby_engine
      when 'mri'     then "#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"
      when 'rubinus' then Rubinius::VERSION
      when 'jruby'   then JRUBY_VERSION
      when 'maglev'  then MAGLEV_VERSION
      else ruby_version
      end
    end

    def platform
      RUBY_PLATFORM
    end

    def hpi_version
      HPI::VERSION
    end

    def to_hash
      SystemInfo.instance_methods(false).inject({}) do |hash, key|
        hash.merge key.to_s => send(key)
      end
    end
  end
end
