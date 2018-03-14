#! /usr/bin/env ruby

lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib)

lib = File.expand_path('../lib/aws', __dir__)
$LOAD_PATH.unshift(lib)

$LOAD_PATH.unshift(__dir__)

require 'tmpdir'
require 'fileutils'
require 'base_consumer'

require 'pry'

class MusicTweetsConsumer < BaseConsumer
  # (see Aws::KCLrb::RecordProcessorBase#process_records)
  def process_records(records, checkpointer)
    last_seq = nil
    records.each do |record|
      begin
        @output.puts Base64.decode64(record['data'])
        @output.flush
        last_seq = record['sequenceNumber']
      rescue => e
        # Make sure to handle all exceptions.
        # Anything you write to STDERR will simply be echoed by parent process
        STDERR.puts "#{e}: Failed to process record '#{record}'"
      end
    end
    checkpoint_helper(checkpointer, last_seq)  if last_seq
  end

end

if __FILE__ == $0
  # Start the main processing loop
  record_processor = MusicTweetsConsumer.new
  driver = Aws::KCLrb::KCLProcess.new(record_processor)
  driver.run
end

