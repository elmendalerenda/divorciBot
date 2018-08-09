require_relative './lib/my_bot'
MyBot.token = ENV["telegram_bot_token"]

desc "setWebhook"
task :setWebhook do

  ARGV.each { |a| task a.to_sym do ; end }
  url = ARGV[1]

  conn = Faraday.new(:url => 'https://api.telegram.org/')
  res = conn.post("/bot#{MyBot.token}/setWebhook", {url: url})
  puts res.body
end
