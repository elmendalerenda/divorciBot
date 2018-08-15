# DivorciBot
A Telegram bot that helps you with your marriage little issues

## Install development environment
Requirements:
 - Ruby 2.5.1
 - Bundler

After meeting the requirement, execute this command to install the development dependencies:

```bash
$> bundler install
```

## Run Tests
After installing the development environment in your local machine(see above), run this command:
```bash
$> bundle exec rspec
```


## Local instance
Running a local instance:

```bash
$> bundle exec rackup
```

And query:
```bash
curl -d '{"message":{"chat":{"id":1},"text":"/start"}}' -H "Content-Type: application/json" -X POST http://localhost:9292/messages
```