class IncomingMessage

  attr_reader :json

  def initialize(params_as_json)
    @json = params_as_json
  end

  def self.build_from_rack_req(req_body)
    return new(JSON.parse(req_body.read))
  end

  def chat_id
    @chat_id ||= @json["message"]["chat"]["id"]
  end

  def text
    @text ||= @json["message"]["text"]
  end
end
