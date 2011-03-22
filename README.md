statsd-rb
=========
A ruby client for [StatsD](https://github.com/etsy/statsd).

Installation
------------

    gem install statsd-rb

Usage
-----
Connecting to a StatsD instance:

    require "statsd"
    client = StatsD::Client.new

By default, clients will connect to `localhost:8125`.  If you need to
connect to a remote server or a different port, use the `:hostname` and
`:port` options.

    client = StatsD::Client.new(:hostname => "statsd", :port => 5000)

### Commands
Once you have a client, sending statistics is easy.

Increment the downloads count:

    client.incr :downloads

Increment the downloads count, telling StatsD that the counter is being
sampled every 10th time.  All commands take an optional last argument
`sample_rate`.

    client.incr :downloads, 0.1

Decrement the invites count by two:

    client.decrby :invites, 2

Time the archive job:

    client.time :archive do
      # something
    end

Send an already calculated timing:

    client.timing :archive, 300  # milliseconds

TODO
----

- Bulk updating

Author
------
Matt Duncan | [mattduncan.org](http://mattduncan.org) | [matt@mattduncan.org](mailto:matt@mattduncan.org)
