require 'spec_helper'
require 'webmock/rspec'
require 'mock_redis'
require_relative '../lib/my_bot'

describe MyBot do

  let(:mock_redis) { MockRedis.new }

  it 'says hi' do
    MyBot.token = "_token_"

    dialogues = [
      { 'id' => '/start',
        'text' => "Hello, World"
      }
    ]

    message = {
      "message" =>
        { "chat" => { "id" => 123 },
          "text" => "/start"
        }
    }

		stub = stub_request(:post, "https://api.telegram.org/bot_token_/sendMessage").
			with( body: {"chat_id"=>"123", "text"=>"Hello, World", "reply_markup"=>"{\"remove_keyboard\":true}"}).
			to_return(status: 200, body: "")

    bot = MyBot.new(dialogues, mock_redis)
		bot.new_message(message)

    expect(stub).to have_been_requested
	end

  it 'jumps from one dialogue to another' do
    MyBot.token = "_token_"

    dialogues = [
      { 'id' => 1 ,
        'text' => "text of section 1" ,
      },
      { 'id' => 'go to section 2',
        'text' => "text of section 2" ,
      }
    ]

    message = {
      "message" =>
        { "chat" => { "id" => 123 },
          "text" => "go to section 2"
        }
    }

    stub =	stub_request(:post, "https://api.telegram.org/bot_token_/sendMessage").
         with( body: {"chat_id"=>"123", "text"=>"text of section 2", "reply_markup"=>"{\"remove_keyboard\":true}"}).
			to_return(status: 200, body: "")

    bot = MyBot.new(dialogues, mock_redis)
		bot.new_message(message)

    expect(stub).to have_been_requested
  end

  it 'ignores a message and continues the dialogue' do
    MyBot.token = "_token_"

    mock_redis.hset('123', 'last_dialogue', '1')

    dialogues = [
      { 'id' => '1' ,
        'text' => 'text of section 1' ,
        'override-message' => 'go to section 2'
      },
      { 'id' => 'go to section 2',
        'text' => 'text of section 2' ,
      }
    ]

    message = {
      "message" =>
        { "chat" => { "id" => 123 },
          "text" => "ignore me"
        }
    }

    stub =	stub_request(:post, "https://api.telegram.org/bot_token_/sendMessage").
         with( body: {"chat_id"=>"123", "text"=>"text of section 2", "reply_markup"=>"{\"remove_keyboard\":true}"}).
			to_return(status: 200, body: "")

    bot = MyBot.new(dialogues, mock_redis)
		bot.new_message(message)

    expect(stub).to have_been_requested
  end

  it 'sends the possible options for a message' do
    MyBot.token = "_token_"

    dialogues = [
      { 'id' => '/start' ,
        'text' => "text of section 1" ,
        'options' => [
          'go to section 2',
          'go to section 3',
        ]
      }
    ]

    message = {
      "message" =>
        { "chat" => { "id" => 123 },
          "text" => "/start"
        }
    }

    stub =	stub_request(:post, "https://api.telegram.org/bot_token_/sendMessage").
         with( body: {"chat_id"=>"123", "text"=>"text of section 1",
                      "reply_markup"=>"{\"keyboard\":[[\"go to section 2\",\"go to section 3\"]]}"}).
			to_return(status: 200, body: "")

    bot = MyBot.new(dialogues, mock_redis)
		bot.new_message(message)

    expect(stub).to have_been_requested
  end
end
