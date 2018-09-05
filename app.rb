require 'rack'
require 'json'

require 'my_bot'
require 'context'

class Bot
  def call(env)
    req = Rack::Request.new(env)
    unless req.path_info.match?(/message/)
      return ['404', {'Content-Type' => 'text/html'}, ['Not Found']]
    end
    request_body = parse_body(req)

    chat_id = request_body["message"]["chat"]["id"]
    context = Context.new(chat_id, DivorciBotApp.redis)

    MyBot.new(DivorciBotApp.dialogues, context).new_message(request_body)

    ['200', {'Content-Type' => 'text/html'}, ['']]
  end

  private

  def parse_body(req)
    JSON.parse(req.body.read)
  end
end
