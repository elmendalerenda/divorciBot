require 'spec_helper'
require 'rack/test'
require_relative '../app.rb'

describe "app" do
  include Rack::Test::Methods

  module DivorciBotApp
    class << self
      def dialogues
      end
      def redis
      end
    end
  end

  def app
    builder = Rack::Builder.new
    builder.run Bot.new
  end

  let(:valid_payload) { {message: {chat: { id: "123"} } }.to_json }

  describe 'routing' do
    describe '/message' do
      it 'returns 200' do
        a_bot = double(:bot, new_message: nil)
        allow(MyBot).to receive(:new).
          and_return(a_bot)

        post '/message', valid_payload

        expect(last_response).to be_ok
      end

      it 'calls the bot' do
        a_bot = double(:bot, new_message: nil)
        allow(MyBot).to receive(:new).
          and_return(a_bot)

        expect(a_bot).to receive(:new_message)

        post '/message', valid_payload
      end
    end

    it 'return 404 when the path in invalid' do
      post '/invalid_path'

      expect(last_response).to be_not_found
    end
  end
end
