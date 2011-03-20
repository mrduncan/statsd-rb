require 'spec_helper'

describe StatsD::Client do
  describe "initialize" do
    it "defaults to localhost:8125" do
      client = described_class.new
      client.hostname.should == "localhost"
      client.port.should == 8125
    end

    it "initializes hostname and port" do
      client = described_class.new(:hostname => "statsd.local", :port => 6000)
      client.hostname.should == "statsd.local"
      client.port.should == 6000
    end

    it "allows port to be specified as a string" do
      client = described_class.new(:port => "6000")
      client.port.should == 6000
    end
  end

  describe "send_data" do
    describe "sending over socket" do
      RSpec::Matchers.define :send_data do |expected|
        match do |actual|
          socket = UDPSocket.new
          socket.bind("127.0.0.1", 9730)
          actual.call
          IO.select([socket])
          req = socket.recvfrom_nonblock(100)
          socket.close
          req[0] == expected
        end
      end

      it "sends single key and value" do
        client = described_class.new(:port => 9730)
        expect { client.send_data :hits => "1|c" }.to send_data "hits:1|c"
      end
    end

    describe "socket connection" do
      before :each do
        @socket = double('socket')
        [:bind, :connect].each { |m| @socket.stub m }
        UDPSocket.stub(:new) { @socket }
        @client = described_class.new(
          :hostname => "statsd.local",
          :port => 6000
        )
      end

      it "binds to 127.0.0.1" do
        @socket.should_receive(:bind).with("127.0.0.1", 0)
        @client.send_data({})
      end

      it "connects to the client hostname and port" do
        @socket.should_receive(:connect).with(
          @client.hostname,
          @client.port
        )
        @client.send_data({})
      end

      it "sends a single key and value" do
        @socket.should_receive(:send).with("hits:1|c", 0)
        @client.send_data :hits => "1|c"
      end

      it "sends multiple keys and values" do
        @socket.should_receive(:send).with("hits:1|c", 0)
        @socket.should_receive(:send).with("downloads:1|c", 0)
        @client.send_data :hits => "1|c", :downloads => "1|c"
      end
    end
  end

  describe "commands" do
    before :each do
      @client = described_class.new
    end

    describe "incr" do
      it "sends the increment" do
        @client.should_receive(:send_data).with(:hits => "1|c")
        @client.incr :hits
      end

      it "sends the specified increment value" do
        @client.should_receive(:send_data).with(:hits => "3|c")
        @client.incr :hits, 3
      end
    end

    describe "decr" do
      it "sends the decrement" do
        @client.should_receive(:send_data).with(:invites => "-1|c")
        @client.decr :invites
      end

      it "sends the specified decrement value" do
        @client.should_receive(:send_data).with(:tickets => "-4|c")
        @client.decr :tickets, 4
      end
    end

    describe "time" do
      it "sends the time" do
        @client.should_receive(:send_data).with({ :archive => "10|ms" }, 1)
        @client.time(:archive) { sleep 0.01 }
      end
    end
  end

  describe "sampling" do
    before :each do
      @client = described_class.new
    end

    describe "time" do
      it "sends the sampled time" do
        @client.should_receive(:send_data).with({ :archive => "10|ms" }, 0.1)
        @client.time(:archive, 0.1) { sleep 0.01 }
      end
    end
  end
end
