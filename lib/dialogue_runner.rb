require 'faraday'
require 'ostruct'

class DialogueRunner
  def self.token=(string); @token=string end
  def self.token; @token end

  def initialize(dialogues, context, telegram_token)
    @dialogue = dialogues
    @context = context
    @telegram_token = telegram_token
  end

  def new_message(incoming_message)
    received_message = incoming_message.text

    last_id = @context.get(:last_dialogue)
    last_dialogue = find_by_id(last_id)

    if(!last_dialogue.override_message.nil?) #delete
      received_message = last_dialogue.override_message
    end

    dialogue = find_by_id(received_message)

    @context.save(:last_dialogue, dialogue.id)
    send_message(dialogue, incoming_message.chat_id)
  end

  private

  def find_by_id(criteria)
    found = @dialogue.find {|e| e["id"] == criteria}
    if(found.nil?)
      found = @dialogue.find {|e| e["default"] == "true"}
    end

    OpenStruct.new(found)
  end

  def send_message(dialogue, chat_id)
    messages = dialogue.text.is_a?(String) ? [dialogue.text] : dialogue.text

    messages.each do |text|
      body = {
        chat_id: chat_id,
        text: text}
      if dialogue.options.nil?
        body[:reply_markup] = {remove_keyboard: true}.to_json
      else
        body[:reply_markup] = { keyboard: dialogue.options.map{|e| [e]}, resize_keyboard: true}.to_json
      end

      conn = Faraday.new(:url => 'https://api.telegram.org/') do |faraday|
        faraday.adapter  :em_http
      end
      conn.post("/bot#{@telegram_token}/sendMessage", body)
    end
  end
end
