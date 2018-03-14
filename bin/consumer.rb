#! /usr/bin/env ruby

lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib)

lib = File.expand_path('../lib/aws', __dir__)
$LOAD_PATH.unshift(lib)

app = File.expand_path('../app', __dir__)
$LOAD_PATH.unshift(app)

require 'tmpdir'
require 'fileutils'
require 'music_tweets_consumer'

if __FILE__ == $0
  # Start the main processing loop
  record_processor = MusicTweetsConsumer.new
  driver = Aws::KCLrb::KCLProcess.new(record_processor)
  driver.run
end

