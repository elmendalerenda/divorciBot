require 'spec_helper'
require 'mock_redis'

require 'context'

describe Context do

  let(:redis) { MockRedis.new }
  let(:context) { Context.new('id', redis) }

  it 'saves a suggestion' do
    context.save_suggestion('any suggestion')

    expect(context.get(:suggestion)).to eq('any suggestion')
  end


  xit 'saves the timestamp when a new id is created'

end
