require 'spec_helper'
require 'rack/test'
require_relative '../app.rb'
require_relative '../lib/my_bot.rb'

describe "app" do
  include Rack::Test::Methods

  def app
    builder = Rack::Builder.new
    builder.run Bot.new
  end

  describe 'routing' do
    describe '/message' do
      it 'returns 200' do
        allow(MyBot).to receive(:new_message)

        post '/message', {}.to_json

        expect(last_response).to be_ok
      end

      it 'calls the bot' do
        expect(MyBot).to receive(:new_message)

        post '/message', {}.to_json
      end
    end

    it 'return 404 when the path in invalid' do
      post '/invalid_path'
      expect(last_response).to be_not_found
    end
  end
end
