require 'faraday'

class MyBot
  def self.token=(string); @token=string end
  def self.token; @token end

  def self.new_message(params)
    chat_id = params["message"]["chat"]["id"]
    received_message = params["message"]["text"]

    conn = Faraday.new(:url => 'https://api.telegram.org/')

    case received_message
    when "/start"
      message = "Hello, World"
      res = conn.post("/bot#{MyBot.token}/sendMessage", {chat_id: chat_id, text: message})
      p res.body
    when "Bien"
      message = "Hablemos entonces de previsiones legales matrimoniales"
      res = conn.post("/bot#{MyBot.token}/sendMessage", {chat_id: chat_id, text: message,
                        reply_markup: {remove_keyboard: true}.to_json
      })
    when "Mal"
      message = "Entiendo, has pensado en una separacion o en divorciarte"
      res = conn.post("/bot#{MyBot.token}/sendMessage", {chat_id: chat_id, text: message,
                        reply_markup: {remove_keyboard: true}.to_json
      })
    else
      message = "Como te llevas con tu pareja?"
      res = conn.post("/bot#{MyBot.token}/sendMessage", {
        chat_id: chat_id,
        text: message,
        reply_markup: { keyboard: [[ "Bien"], ["Mal"]]}.to_json
      })
      # p res.body
    end

    # "{\"ok\":false,\"error_code\":400,\"description\":\"Bad Request: chat_id is empty\"}"
  end
end
