require 'benchmark'
require 'socket'

module StatsD
  class Client
    attr_reader :hostname, :port

    def initialize(options = {})
      @hostname = options[:hostname] || "localhost"
      @port = (options[:port] || 8125).to_i
    end

    def time(key, sample_rate = 1, &block)
      seconds = Benchmark.realtime { block.call }
      timing(key, (seconds * 1000).round, sample_rate)
    end

    def timing(key, ms, sample_rate = 1)
      send_data({ key => "#{ms}|ms" }, sample_rate)
    end

    def incr(key, sample_rate = 1)
      incrby(key, 1, sample_rate)
    end

    def incrby(key, increment, sample_rate = 1)
      send_data({ key => "#{increment}|c" }, sample_rate)
    end

    def decr(key, sample_rate = 1)
      decrby(key, 1, sample_rate)
    end

    def decrby(key, decrement, sample_rate = 1)
      incrby(key, -decrement, sample_rate)
    end

    def send_data(data, sample_rate = 1)
      socket = UDPSocket.new
      socket.bind("127.0.0.1", 0)
      socket.connect(@hostname, @port)
      data.each do |key, val|
        val += "|@#{sample_rate}" if sample_rate != 1
        socket.send "#{key}:#{val}", 0
      end
    end
  end
end
