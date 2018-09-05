require 'redis'

class Context
  def initialize(id, redis)
    @redis = redis
    @id = id
  end

  def save(key, value)
    @redis.hset(@id, key, value)
  end

  def get(key)
    @redis.hget(@id, key)
  end
end
