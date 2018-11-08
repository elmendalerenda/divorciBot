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

  def save_suggestion(text)
    save(:suggestion, text)
  end

  def save_previous_dialogue(text)
    save(:previous_dialogue, text)
  end

  def get_previous_dialogue
    get(:previous_dialogue)
  end
end
