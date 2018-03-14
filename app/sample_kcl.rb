require 'base64'
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
  # (see Aws::KCLrb::RecordProcessorBase#shutdown)
  def shutdown(checkpointer, reason)
    checkpoint_helper(checkpointer)  if 'TERMINATE' == reason
  ensure
    # Make sure to cleanup state
  end

  # (see Aws::KCLrb::RecordProcessorBase#shutdown_requested)
  def shutdown_requested(checkpointer)
    checkpoint_helper(checkpointer)
  end

  protected
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


