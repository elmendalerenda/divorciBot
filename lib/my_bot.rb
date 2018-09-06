require 'faraday'

class MyBot
  def self.token=(string); @token=string end
  def self.token; @token end

  def initialize(dialogues, context)
    @dialogue = dialogues
    @context = context
  end

  def new_message(incoming_message)
    received_message = incoming_message.text

    last_id = @context.get(:last_dialogue)
    last_dialogue = @dialogue.find {|e| e["id"] == last_id}

    if(!last_dialogue.nil? && !last_dialogue["override-message"].nil?)
      received_message = last_dialogue["override-message"]
    end

    dialogue = @dialogue.find {|e| e["id"] == received_message}
    unless (dialogue.nil?)
      message = dialogue["text"]
      @context.save(:last_dialogue, dialogue["id"])
      body = {
        chat_id: incoming_message.chat_id,
        text: message}
      if dialogue["options"].nil?
        body[:reply_markup] = {remove_keyboard: true}.to_json
      else
        body[:reply_markup] = { keyboard: [dialogue["options"]]}.to_json
      end

      send_message(body)
    end
  end

  private

  def send_message(body)
    if MyBot.token.nil?
      p "Intercepted message with payload: #{body}"
    else
      conn = Faraday.new(:url => 'https://api.telegram.org/')
      conn.post("/bot#{MyBot.token}/sendMessage", body)
    end
  end
end
