require 'rack'
require 'json'

require 'dialogue_runner'
require 'context'
require 'incoming_message'

class BotWebhookController
  def call(env)
    req = Rack::Request.new(env)
    unless req.path_info.match?(/message/)
      return ['404', {'Content-Type' => 'text/html'}, ['Not Found']]
    end

    incoming_message = IncomingMessage.build_from_rack_req(req.body)
    context = Context.new(incoming_message.chat_id, App.redis)

    DialogueRunner.new(App.dialogues, context, App.telegram_token).new_message(incoming_message)

    ['200', {'Content-Type' => 'text/html'}, ['']]
  end
end
