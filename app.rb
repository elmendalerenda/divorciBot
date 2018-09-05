require 'rack'
require 'json'
require 'my_bot'

class Bot
  def call(env)
    req = Rack::Request.new(env)
    unless req.path_info.match?(/message/)
      return ['404', {'Content-Type' => 'text/html'}, ['Not Found']]
    end

    MyBot.new(DivorciBotApp.dialogues, DivorciBotApp.redis).new_message(JSON.parse(req.body.read))

    ['200', {'Content-Type' => 'text/html'}, ['']]
  end
end
