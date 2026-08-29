require_relative "../stage_result"
require_relative "../sensor_message"

class Deduplicator
  def initialize(store:)
    unless store.respond_to?(:include?) && store.respond_to?(:add)
      raise ArgumentError, "store must respond to include? and add"
    end

    @store = store
  end

  def call(message)
    unless message.is_a?(SensorMessage)
      return(
        StageResult.failure(
          TypeError.new("Deduplicator requires a SensorMessage")
        )
      )
    end

    if @store.include?(message.message_id)
      return StageResult.drop("Duplicate message")
    end

    @store.add(message.message_id)
    StageResult.pass(message)
  end
end
