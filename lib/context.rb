require 'redis'

class Context
  def initialize(redis, id)
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
