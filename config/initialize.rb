module App
  class << self
    def dialogues
      file = File.read('./config/dialogues.json')
      JSON.parse(file)
    end

    def redis
      @redis ||= Redis.new(url: ENV['REDIS_URL'])
    end

    def telegram_token
      ENV['telegram_bot_token']
    end
  end
end
