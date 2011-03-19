require 'benchmark'
require 'socket'

module StatsD
  class Client
    attr_reader :hostname, :port

    def initialize(options = {})
      @hostname = options[:hostname] || "localhost"
      @port = (options[:port] || 8125).to_i
    end

    def time(key, &block)
      seconds = Benchmark.realtime { block.call }
      ms = (seconds * 1000).round
      send_data key => "#{ms}|ms"
    end

    def incr(key, increment = 1)
      send_data key => "#{increment}|c"
    end

    def decr(key, decrement = 1)
      incr(key, -decrement)
    end

    def send_data(data)
      socket = UDPSocket.new
      socket.bind("127.0.0.1", 0)
      socket.connect(@hostname, @port)
      data.each do |key, val|
        socket.send "#{key}:#{val}", 0
      end
    end
  end
end
