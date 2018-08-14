require 'rack'
require 'json'
require_relative 'lib/my_bot'

class Bot
  def call(env)
    req = Rack::Request.new(env)
    unless req.path_info.match?(/message/)
      return ['404', {'Content-Type' => 'text/html'}, ['Not Found']]
    end

    dialogues = [
      { id: '/start', text: 'Bienvenido! tengo una pregunta para ti, como te llevas con tu pareja?',
        options: [ 'Bien', 'Mal']},
      { id: 'Bien', text: 'Hablemos entonces de previsiones legales matrimoniales'},
      { id: 'Mal', text:  'Entiendo, has pensado en una separacion o en divorciarte' }
    ]

    bot = MyBot.new(dialogues)
    bot.new_message(JSON.parse(req.body.read))

    ['200', {'Content-Type' => 'text/html'}, ['']]
  end
end
