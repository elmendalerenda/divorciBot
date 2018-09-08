lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require_relative 'config/initialize'
require_relative 'app'

DialogueRunner.token = ENV["telegram_bot_token"]
run BotWebhookController.new
