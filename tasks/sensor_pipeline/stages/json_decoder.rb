require "json"
require_relative "../stage_result"

class JsonDecoder
  def call(json)
    data = JSON.parse(json, symbolize_names: true)
    StageResult.pass(data)
  rescue JSON::ParserError => error
    StageResult.failure(error)
  end
end
