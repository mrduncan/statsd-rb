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
      ms = (seconds * 1000).round
      send_data({ key => "#{ms}|ms" }, sample_rate)
    end

    def incr(key)
      incrby(key, 1)
    end

    def incrby(key, increment)
      send_data key => "#{increment}|c"
    end

    def decr(key)
      decrby(key, 1)
    end

    def decrby(key, decrement)
      incrby(key, -decrement)
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
