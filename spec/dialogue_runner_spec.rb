require 'spec_helper'
require 'webmock/rspec'
require 'mock_redis'

require 'dialogue_runner'
require 'context'
require 'incoming_message'

describe DialogueRunner do

  let(:chat_id) { "123" }
  let(:mock_context) { Context.new(chat_id, MockRedis.new) }
  let(:telegram_token) { '_token_' }

  it 'says hi' do
    dialogues = [
      { 'id' => '/start',
        'text' => "Hello, World"
      }
    ]
    bot = DialogueRunner.new(dialogues, mock_context, telegram_token)
    expected_request = stub_basic_telegram_request("Hello, World")

    bot.new_message(compose_payload_with_text("/start"))

    expect(expected_request).to have_been_requested
  end

  it 'answers with a default option' do
    dialogues = [
      { 'id' => 'Default',
        'text' => "I do not understand",
        'default' => 'true'
      }
    ]
    bot = DialogueRunner.new(dialogues, mock_context, telegram_token)
    expected_request = stub_basic_telegram_request("I do not understand")

    bot.new_message(compose_payload_with_text("random stuff"))

    expect(expected_request).to have_been_requested
  end

  it 'splits a text into different messages' do
    dialogues = [
      { 'id' => 'split',
        'text' => ['first message', 'second message']
      }
    ]
    bot = DialogueRunner.new(dialogues, mock_context, telegram_token)
    expected_request = stub_basic_telegram_request('first message')
    second_expected_request = stub_basic_telegram_request('second message')

    bot.new_message(compose_payload_with_text('split'))

    expect(expected_request).to have_been_requested
    expect(second_expected_request).to have_been_requested
  end

  it 'jumps from one dialogue to another' do
    dialogues = [
      { 'id' => 1 ,
        'text' => "text of section 1" ,
    },
    { 'id' => 'go to section 2',
      'text' => "text of section 2" ,
    }
    ]
    bot = DialogueRunner.new(dialogues, mock_context, telegram_token)
    expected_request = stub_basic_telegram_request("text of section 2")

    bot.new_message(compose_payload_with_text("go to section 2"))

    expect(expected_request).to have_been_requested
  end

  it 'ignores a message and continues the dialogue' do
    mock_context.save_previous_dialogue('1')

    dialogues = [
      { 'id' => '1' ,
        'text' => 'text of section 1' ,
        'override_message' => 'go to section 2'
      },
      { 'id' => 'go to section 2',
        'text' => 'text of section 2' ,
      }
    ]
    bot = DialogueRunner.new(dialogues, mock_context, telegram_token)
    expected_request = stub_basic_telegram_request("text of section 2")

    bot.new_message(compose_payload_with_text("ignore me"))

    expect(expected_request).to have_been_requested
  end

  it 'sends the possible options for a message' do
    dialogues = [
      { 'id' => '/start' ,
        'text' => "text of section 1" ,
        'options' => [
          'go to section 2',
          'go to section 3',
        ]
    }
    ]
    bot = DialogueRunner.new(dialogues, mock_context, telegram_token)

    expected_request = stub_request(:post, "https://api.telegram.org/bot#{telegram_token}/sendMessage").
      with( body: {"chat_id"=>chat_id, "text"=>"text of section 1",
                   "reply_markup"=>"{\"keyboard\":[[\"go to section 2\"],[\"go to section 3\"]],\"resize_keyboard\":true}"}).
      to_return(status: 200, body: "")

    bot.new_message(compose_payload_with_text("/start"))

    expect(expected_request).to have_been_requested
  end

  it 'stores suggestions' do
    dialogues = [
      { 'id' => '/sugerencia' ,
        'text' => "thank you"
      }
    ]
    bot = DialogueRunner.new(dialogues, mock_context, telegram_token)

    expect(mock_context).to receive(:save_suggestion).with("esto es una sugerencia")
    stub_basic_telegram_request("thank you")

    bot.new_message(compose_payload_with_text("/sugerencia esto es una sugerencia"))
  end

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
    stub_request(:post, "https://api.telegram.org/bot#{telegram_token}/sendMessage").
      with( body: {"chat_id"=> chat_id, "text" => text, "reply_markup"=>"{\"remove_keyboard\":true}"}).
      to_return(status: 200, body: "")
  end
end
