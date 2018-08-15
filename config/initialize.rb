module DivorciBotApp
  class << self
    def dialogues
      file = File.read('./config/dialogues.json')
      JSON.parse(file)
    end
  end
end
