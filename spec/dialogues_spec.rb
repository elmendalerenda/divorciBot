require 'spec_helper'

describe 'dialogues file' do
  it 'is correct' do
    file = File.read('./config/dialogues.json')
    JSON.parse(file)
  end
end
