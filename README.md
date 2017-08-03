# Xyeger

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'xyeger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install xyeger

## Basic Usage
Xyeger Logger was created to be suitable with ElasticSearch logs, so when you log anything you will get JSON representation of your message. 

```ruby
  require 'active_support'
  logger = ActiveSupport::Logger.new(STDOUT)
  logger.extend(Xyeger::Logger)
  logger.info('Some message')
```

It was found out that just JSON-looking logs does not solve the problem of tracking request flow. So context was added. 

You


### Configuration

Add environments:
```bash
XYEGER_HOSTNAME='localhost' #f.e.: rails, sidekiq, sneakers
XYEGER_APPNAME='some_service'
XYEGER_ENV='staging'
```

Add into initializer file:
```ruby
#config/initializers/xyeger.rb
Xyeger.configure do |config|
  config.output = STDOUT # default
  config.formatter = MyCustomFormatter # default to Xyeger::Formatters::Json.new
  config.app = Rails.application.class.parent_name # default to ENV['XYEGER_APPNAME'] or emtpy string
  config.env = Rails.env # default to ENV['XYEGER_ENV'] or empty string
  config.context_resolver = MyContextResolver # ContextResolver class
  config.message_resolver = MyMessageResolver # MessageResolver class
end
```
|          Formatter           |   Description    |
| ---------------------------- | ---------------- |
| `Xyeger::Formatters::Base`   |                  |
| `Xyeger::Formatters::Json`   | default format   |
| `Xyeger::Formatters::Values` | show only values |
| `Xyeger::Formatters::Text`   | show text form   |


## Output results

### Http request
```bash
curl localhost:3000 -G -d a=3
```
```json
{
 "logger": "puma: cluster worker 1: 29117 [cryptopay]",
 "pid": 29141,
 "app": "Cryptopay",
 "env": "development",
 "level": "INFO",
 "time": "2017-06-29T15:42:14.761+03:00",
 "caller": null,
 "msg": "some message",
 "context":
  {"method": "GET",
   "path": "/",
   "format": "*/*",
   "controller": "PagesController",
   "action": "index",
   "status": 200,
   "duration": 1852.79,
   "view": 703.55,
   "db": 29.07,
   "params": {"a": "3"}}
}
```

### Raise an error
```json
{
  "logger":"puma",
  "pid":24886,
  "app":"Cryptopay",
  "env":"development",
  "level":"ERROR",
  "time":"2017-06-29T15:17:07.736+03:00",
  "caller":"/home/vsevolod/work/cryptopay/cryptopay/app/services/ticker_service.rb:159",
  "msg": "StandardError",
  "context":
   {
        "class": "TickerService::TickerNotFound",
        "error": "Active ticker not found EUR/USD"
   }
}
```

### Manual log usage
```ruby
Rails.logger.info('Logger message', { content: '1', params: 'b' })
```
```json
{
  "logger":"bin/rails",
  "pid":22796,
  "app":"Cryptopay",
  "env":"development",
  "level":"INFO",
  "time":"2017-06-30T13:45:22.070+03:00",
  "caller":null,
  "message":"Logger message",
  "context":
  {
    "content":"1",
    "params":"b"
  }
}

```

## Grape usage
WIth ```gem 'grape_logging'```
```ruby
class Root < Grape::API
  # Message: {
  #  "status":200,
  #  "time":
  #  {
  #    "total":86.84,
  #    "db":15.27,
  #    "view":71.57
  #  },
  #  "method":"GET",
  #  "path":"/api/v2/tickers",
  #  "params":{"password":"[FILTERED]","a":"b"},
  #  "ip":"127.0.0.1",
  #  "ua":"Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:54.0) Gecko/20100101 Firefox/54.0"
  #}
  formatter = Xyeger::Formatters::Json.new(
    message: ->(message, _context) { "#{message[:method]} #{message[:path]}" },
    context: ->(message, _context) { message }
  )

  use GrapeLogging::Middleware::RequestLogger,
    logger: logger,
    formatter: formatter,
    include: [
      GrapeLogging::Loggers::Response.new,
      GrapeLogging::Loggers::FilterParameters.new,
      GrapeLogging::Loggers::ClientEnv.new
    ]
end
```

## Sidekiq usage

```ruby
# config/initializers/xyeger.rb
Sidekiq::Logging.logger.formatter = Xyeger::Formatters::SidekiqJson.new
```

## TaggedLogging example

```ruby
Rails.logger.tagged('main', 'object_id') { Rails.logger.info('Message text', { id: 33 }) }
```
```json
{
  "pid" : 9210,
  "app" : "Cryptopay",
  "env" : "development",
  "level" : "INFO",
  "time" : "2017-07-18T19:42:53.373+03:00",
  "message" : "Message text",
  "context" : {
    "id" : 33
  },
  "tags" : [
    "main",
    "object_id"
  ]
}
```


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

