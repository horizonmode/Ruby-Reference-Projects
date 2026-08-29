require_relative "../stage_result"

class Deduplicator
  def initialize(store:)
    @store = store
  end

  def call(message)
    if @store.include?(message.message_id)
      return StageResult.drop("Duplicate message")
    end

    @store.add(message.message_id)
    StageResult.pass(message)
  end
end
