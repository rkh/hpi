require 'hpi'

module HPI
  class Result
    class Distribution
      include Comparable

      attr_accessor :min, :avg, :max, :median, :stddev
      alias proxy_respond_to? respond_to?

      def initialize(min, avg, max, median, stddev)
        @min, @avg, @max, @median, @stddev
      end

      def <=>(other)
        return to_f <=> other.to_f unless other.respond_to? :avg
        to_a <=> other.to_a
      end

      def to_a
        [avg, median, stddev, max, min]
      end

      def respond_to?(*args)
        super or avg.respond_to?(*args)
      end

      def public_send(method, *args, &block)
        return super if proxy_respond_to? method
        avg.public_send(method, *args, &block)
      end

      def send(method, *args, &block)
        return super if proxy_respond_to? method, true
        avg.send(method, *args, &block)
      end

      def method_missing(*a, &b)
        avg.public_send(*a, &b)
      end
    end

    def self.parse(src)
      result = new
      result.parse(src)
      result
    end

    attr_reader :max_burst,   :duration,        :user_time,       :system_time,       :cpu_usage
    attr_reader :requests,    :request_rate,    :request_time,    :request_size
    attr_reader :replies,     :reply_rate,      :reply_time,      :reply_size,        :reply_status
    attr_reader :connections, :connection_rate, :connection_time, :connection_length
    attr_reader :header,      :content,         :footer,          :transfer_time,     :net_io

    def parse(src)
      src.each_line { |line| parse_line(line) }
    end

    def parse_line(line)
      title, data = line.shop.split(": ", 2)
      parse_value(title, data) if data
    end

    def parse_numbers(value)
      value.scan(/(\d+\.\d+)|(\d+)/).map { |f,i| f ? f.to_f : i.to_i }
    end

    def parse_avg(value)
      return unless value.start_with? "min "
      Distribution.new(*parse_numbers(value)[0, 5])
    end

    def parse_status(value)
      value.scan(/(\dxx)=(\d+)/).inject({}) { |h, (k,v)| h.merge k => Integer(v) }
    end

    def parse_value(key, value)
      case key
      when "Maximum connect burst length"     then @max_burst                                   = Integer(value)
      when "Total"                            then @connections, @requests, @replies, @duration = parse_numbers(value)
      when "Connection rate"                  then @connection_rate, _                          = parse_numbers(value)
      when "Connection time [ms]"             then @connection_time                           ||= parse_avg(value)
      when "Connection length [replies/conn]" then @connection_length                           = Float(value)
      when "Request rate"                     then @request_rate, @request_time                 = parse_numbers(value)
      when "Request size [B]"                 then @request_size                                = Float(value)
      when "Reply rate [replies/s]"           then @reply_rate                                ||= parse_avg(value)
      when "Reply time [ms]"                  then @reply_time, @transfer_time                  = parse_numbers(value)
      when "Reply size [B]"                   then @header, @content, @footer, @reply_size      = parse_numbers(value)
      when "Reply status"                     then @reply_status                                = parse_status(value)
      when "CPU time [s]"                     then @user_time, @system_time, _, _, @cpu_usage   = parse_numbers(value)
      when "Net I/O"                          then @net_io                                      = value
      when "Errors"                           then nil
      else raise ArgumentError, "unknown key: #{key.inspect}"
    end
  end
end
