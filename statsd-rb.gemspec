$LOAD_PATH.unshift 'lib'
require 'statsd/version'

Gem::Specification.new do |s|
  s.name              = "statsd-rb"
  s.version           = StatsD::Version
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "A ruby client for StatsD."
  s.homepage          = "http://github.com/mrduncan/statsd"
  s.email             = "matt@mattduncan.org"
  s.authors           = ["Matt Duncan"]

  s.files             = %w( README.md Rakefile LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("spec/**/*")

  s.description = <<description
    A ruby client for Etsy's StatsD statistics aggregator.
description
end
