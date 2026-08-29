require "json"
require_relative "../stage_result"

class JsonDecoder
  def call(json)
    unless json.is_a?(String)
      return StageResult.failure(TypeError.new("JsonDecoder requires a String"))
    end

    data = JSON.parse(json, symbolize_names: true)
    StageResult.pass(data)
  rescue JSON::ParserError => error
    StageResult.failure(error)
  end
end
