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

  it 'saves the timestamp when a new id is created' do
    id = 'any_id'
    t = Time.now
    expect(redis.exists(id)).to eql(false)
    allow(Time).to receive(:now).and_return(t)

    Context.new(id, redis)

    expect(redis.hget(id, :created_at)).to eql(t.to_s)
  end

  it 'does not override the created timestamp' do
    id = 'any_id'
    now = Time.now
    future = now + 30
    allow(Time).to receive(:now).and_return(now)

    Context.new(id, redis)

    allow(Time).to receive(:now).and_return(future)

    Context.new(id, redis)

    expect(redis.hget(id, :created_at)).to eql(now.to_s)
  end
end
