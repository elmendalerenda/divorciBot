require 'spec_helper'
require 'webmock/rspec'
require_relative '../lib/my_bot'

describe MyBot do
  it 'says hi' do
    MyBot.token = "_token_"

    message = {
      "message" =>
        { "chat" => { "id" => 123 },
          "text" => "/start"
        }
    }

		stub_request(:post, "https://api.telegram.org/bot_token_/sendMessage").
			with( body: {"chat_id"=>"123", "text"=>"Hello, World"}).
			to_return(status: 200, body: "")

		MyBot.new_message(message)
	end
end
