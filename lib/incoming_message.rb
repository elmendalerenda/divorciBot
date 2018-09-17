require 'app_logger'


class IncomingMessage

  attr_reader :json

  def initialize(params_as_json)
    @json = params_as_json
  end

  def self.build_from_rack_req(req_body)
    pars = req_body.read
    return new(JSON.parse(pars))
  rescue JSON::ParserError
    AppLogger.log.error("Error parsing the incoming message: #{pars}")
    raise
  end

  def chat_id
    @chat_id ||= @json["message"]["chat"]["id"]
  end

  def text
    @text ||= @json["message"]["text"]
  end
end
