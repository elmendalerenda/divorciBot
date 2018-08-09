require_relative 'app'

MyBot.token = ENV["telegram_bot_token"]

run Bot.new
