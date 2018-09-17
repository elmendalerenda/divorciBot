require 'spec_helper'

describe IncomingMessage do
  describe '#build_from_rack_req' do
    it 'logs input params when parsing an invalid json' do
      message = double(:message, read: 'invalid json')
      log = double('log')
      AppLogger.log = log

      expect(log).to receive(:error).with("Error parsing the incoming message: invalid json")

      expect{ IncomingMessage.build_from_rack_req(message) }.to raise_error(JSON::ParserError)
    end
  end
end
