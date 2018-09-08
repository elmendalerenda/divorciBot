require 'spec_helper'
require 'webmock/rspec'
require 'mock_redis'

require 'my_bot'
require 'context'
require 'incoming_message'

describe MyBot do

  let(:chat_id) { "123" }
  let(:mock_context) { Context.new(chat_id, MockRedis.new) }

  def compose_payload_with_text(text)
    IncomingMessage.new(
      {
        "message" =>
        { "chat" => { "id" => chat_id },
          "text" => text
        }
      }
    )
  end

  def stub_basic_telegram_request(text)
    stub_request(:post, "https://api.telegram.org/bot_token_/sendMessage").
      with( body: {"chat_id"=> chat_id, "text" => text, "reply_markup"=>"{\"remove_keyboard\":true}"}).
      to_return(status: 200, body: "")
  end

  it 'says hi' do
    MyBot.token = "_token_"

    dialogues = [
      { 'id' => '/start',
        'text' => "Hello, World"
      }
    ]
    bot = MyBot.new(dialogues, mock_context)
    expected_request = stub_basic_telegram_request("Hello, World")

    bot.new_message(compose_payload_with_text("/start"))

    expect(expected_request).to have_been_requested
  end

  it 'answers with a default option' do
    MyBot.token = "_token_"

    dialogues = [
      { 'id' => '/start',
        'text' => "Hello, World"
      },
      { 'id' => 'Default',
        'text' => "I do not understand",
        'default' => 'true'
      },

    ]
    bot = MyBot.new(dialogues, mock_context)
    expected_request = stub_basic_telegram_request("I do not understand")

    bot.new_message(compose_payload_with_text("random stuff"))

    expect(expected_request).to have_been_requested
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
    bot = MyBot.new(dialogues, mock_context)
    expected_request = stub_basic_telegram_request("text of section 2")

    bot.new_message(compose_payload_with_text("go to section 2"))

    expect(expected_request).to have_been_requested
  end

  it 'ignores a message and continues the dialogue' do
    MyBot.token = "_token_"

    mock_context.save(:last_dialogue, '1')

    dialogues = [
      { 'id' => '1' ,
        'text' => 'text of section 1' ,
        'override_message' => 'go to section 2'
    },
    { 'id' => 'go to section 2',
      'text' => 'text of section 2' ,
    }
    ]
    bot = MyBot.new(dialogues, mock_context)
    expected_request = stub_basic_telegram_request("text of section 2")

    bot.new_message(compose_payload_with_text("ignore me"))

    expect(expected_request).to have_been_requested
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
    bot = MyBot.new(dialogues, mock_context)

    expected_request = stub_request(:post, "https://api.telegram.org/bot_token_/sendMessage").
      with( body: {"chat_id"=>chat_id, "text"=>"text of section 1",
                   "reply_markup"=>"{\"keyboard\":[[\"go to section 2\",\"go to section 3\"]]}"}).
      to_return(status: 200, body: "")

    bot.new_message(compose_payload_with_text("/start"))

    expect(expected_request).to have_been_requested
  end
end
