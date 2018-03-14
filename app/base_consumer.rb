#! /usr/bin/env ruby

lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib)

lib = File.expand_path('../lib/aws', __dir__)
$LOAD_PATH.unshift(lib)

require 'base64'
require 'tmpdir'
require 'fileutils'
require 'kclrb'

require 'pry'

# @api private
# A sample implementation of the {Aws::KCLrb::RecordProcessorBase RecordProcessor}.
#
# All it does is write the data to an output stream. Be careful not to use
# the `$stdout` as it's used to communicate with the {https://github.com/awslabs/amazon-kinesis-client/blob/master/src/main/java/com/amazonaws/services/kinesis/multilang/package-info.java MultiLangDaemon}.
# If you use `$stderr` instead the MultiLangDaemon would echo the output
# to its own standard error stream.
class BaseConsumer < Aws::KCLrb::RecordProcessorBase
  # @param output [IO, String] If a string is provided, it's assumed to be the path
  #   to an output directory. That directory would be created and permissions to write
  #   to it are asserted.
  def initialize(output=$stderr)
    if output.is_a?(String)
      @output_directory = output
      # Make sure the directory exists and that we can
      # write to it. If not, this will fail and processing
      # can't start.
      FileUtils.mkdir_p @output_directory
      probe_file = File.join(@output_directory, '.kclrb_probe')
      FileUtils.touch(probe_file)
      FileUtils.rm(probe_file)
    elsif output
      # assume it's an IO
      @output = output
    else
      fail "Output destination cannot be nil"
    end
  end

  # (see Aws::KCLrb::RecordProcessorBase#init_processor)
  def init_processor(shard_id)
    unless @output
      @filename = File.join(@output_directory, "#{shard_id}-#{Time.now.to_i}.log")
      @output = open(@filename, 'w')
    end
  end

  # (see Aws::KCLrb::RecordProcessorBase#shutdown)
  def shutdown(checkpointer, reason)
    checkpoint_helper(checkpointer)  if 'TERMINATE' == reason
  ensure
    # Make sure to cleanup state
    @output.close unless @output.closed?
  end

  # (see Aws::KCLrb::RecordProcessorBase#shutdown_requested)
  def shutdown_requested(checkpointer)
    checkpoint_helper(checkpointer)
  end

  private
  # Helper method that retries checkpointing once.
  # @param checkpointer [Aws::KCLrb::Checkpointer] The checkpointer instance to use.
  # @param sequence_number (see Aws::KCLrb::Checkpointer#checkpoint)
  def checkpoint_helper(checkpointer, sequence_number=nil)
    begin
      checkpointer.checkpoint(sequence_number)
    rescue Aws::KCLrb::CheckpointError => e
      # Here, we simply retry once.
      # More sophisticated retry logic is recommended.
      checkpointer.checkpoint(sequence_number) if sequence_number
    end
  end
end

if __FILE__ == $0
  # Start the main processing loop
  record_processor = BaseConsumer.new(ARGV[1] || File.join(Dir.tmpdir, 'kclrbsample'))
  driver = Aws::KCLrb::KCLProcess.new(record_processor)
  driver.run
end

