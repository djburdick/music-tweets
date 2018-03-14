require 'base_consumer'

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

