# Xyeger

## Table of content

- [Basic Usage](#basic-usage)
  - [Installation](#installation)
  - [Configuration](#configuration)
  - [Context](#context)
  - [Context Resolver](#context-resolver)
  - [Message Resolver](#message-resolver) 
- [Formatters](#formatters)
  - [Base Formatter](#base-formatter)
  - [JSON Formatter](#json-formatter)
  - [Values Formatter](#values-formatter)
  - [Text Formatter](#text-formatter)
  - [Custom Formatter](#custom-formatter)
- [Integrations](#integrations)
  - [Rails](#rails)
  - [Grape](#grape)
  - [Sidekiq](#sidekiq)
  - [Sentry](#sentry)
  - [Plain ruby app](#plain-ruby-app)
## Basic Usage
Xyeger Logger was created to be suitable with ElasticSearch logs, so when you log anything you will get JSON representation of your message. 

```ruby
Xyeger.configure {}
logger = Logger.new(STDOUT)
logger.extend(Xyeger::Logger)
logger.info('Some message')
```

```json
{
  "hostname": "",
  "pid": 61915,
  "app": "",
  "env": "",
  "level": "INFO",
  "time": "2017-08-03 16:24:57 +0300",
  "message": "Some message",
  "context": {}
}
```

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'xyeger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install xyeger

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
  config.output = STDOUT                      # default to STDOUT
  config.formatter = MyCustomFormatter        # default to Xyeger::Formatters::Json.new
  config.app = ''                             # default to ENV['XYEGER_APPNAME'] or emtpy string
  config.env = Rails.env                      # default to ENV['XYEGER_ENV'] or empty string
  config.context_resolver = MyContextResolver # ContextResolver class
  config.message_resolver = MyMessageResolver # MessageResolver class
end
```

### Context
It was found out that just JSON-looking logs does not solve the problem of tracking request flow. So context was added. 

```ruby
  Xyeger.add_context(flow_id: SecureRandom.uuid)
  logger.debug('With Context')
```

```json
{
  "hostname": "",
  "pid": 61915,
  "app": "",
  "env": "",
  "level": "DEBUG",
  "time": "2017-08-03 16:26:38 +0300",
  "message": "With Context",
  "context": {
    "flow_id": "6821a053-ad20-4d58-905a-25a923f7a412"
  }
}
```

### Context Resolver

You are not wired to add only hash object to context, but in that keys you might want to create your own `ContextResolver`, which expect `self.call(object)` method and return hash-representation at the end.

```ruby
class MyContextResolver
  def self.call(object)
    case object
    when User
      { user_id: object.uuid }
    end
  end
end  

Xyeger.configure { config.context_resolver = MyContextResolver }

user = User.first
Xyeger.add_context(user)
```

### Message Resolver

Same way as it is done in context resolver you might find useful to create your own `MessageResolver`, which expect `self.call(message, progname)` method to be implemented and return string at the end.

```ruby
class MessageResolver
  def self.call(message, progname)
    message =
      case message
      when ::StandardError
        [message.class.name, message].join(' ')
      else
        message.to_s
      end
    [progname, message].join(' ')
  end
end

Xyeger.configure { config.message_resolver = MyContextResolver }

begin
  raise
rescue => error
  Xyeger.add_context(error)
  raise error
end
```


## Formatters
By default you have following formatters

|          Formatter           |   Description    |
| ---------------------------- | ---------------- |
| `Xyeger::Formatters::Base`   |                  |
| `Xyeger::Formatters::Json`   | default formater |
| `Xyeger::Formatters::Values` | show only values |
| `Xyeger::Formatters::Text`   | show text form   |

### Base formatter
All built-in formatters inherit from `Xyeger::Formatters::Base`, which prepare result hash with following keys: `hostname`, `pid`, `app`, `env`, `level`, `time`, `message`, `context`.

### JSON Formatter
Default representation of logs:

```ruby
logger.formatter = Xyeger::Formatters::Json.new # default formatter
```
```json
{
  "hostname": "",
  "pid": 61915,
  "app": "",
  "env": "",
  "level": "DEBUG",
  "time": "2017-08-03 16:26:38 +0300",
  "message": "With Context ",
  "context": {
    "flow_id": "6821a053-ad20-4d58-905a-25a923f7a412"
  }
}
```

### Values Formatter
All the values of Base formatter hash concatenated with `space` delimiter.

```ruby
logger.formatter = Xyeger::Formatters::Values.new
```
```
 61915   DEBUG 2017-08-03 17:00:07 +0300 With Context  {:flow_id=>"6821a053-ad20-4d58-905a-25a923f7a412"}
```

### Text Formatter
Context represented via list of key-value. Message is just string at the end 

```ruby
logger.formatter = Xyeger::Formatters::Text.new
```
```
 [2017-08-03 16:59:51 +0300] [DEBUG] flow_id=6821a053-ad20-4d58-905a-25a923f7a412 With Context 
```

### Custom Formatter
You are free to implement your own formatters, but things to be mentioned: if you need all default keys accessible inside your formatter, you have to inherit from `Xyeger::Formatters::Base` formatter. See `lib/xyeger/formatters` directory for more info.

## Integrations
You can easily use `Xyeger` with different type of applications and here are some built in integrations

### Rails
Integration with `rails` add `Xyeger::Rails::FlowIdMiddlare` in application middlware stack so it will automatically add end-to-end identifier(`:fid`) inside context for each request and clear it out when request is ended.

### Grape
Grape has it's own logger inside. Most of the time you create extra module to specify logging preferences. It may look something like that.

```ruby
module API
  module Helpers
    module Logger
      extend ActiveSupport::Concern

      included do
        logger.extend(Xyeger::Logger)
        logger.formatter = Xyeger.config.formatter

        use GrapeLogging::Middleware::RequestLogger,
          logger: logger,
          formatter: logger.formatter,
          include: [
            GrapeLogging::Loggers::Response.new,
            GrapeLogging::Loggers::FilterParameters.new,
            GrapeLogging::Loggers::ClientEnv.new
          ]
      end
    end
  end
end
```

So inside your application you just include `API::Helpers::Logger`

```ruby
module API
  class Root < Grape::API
    include API::Helpers::Logger
  end
end
```

### Sidekiq
Sidekiq integration is really useful too. It store `fid` inside job and you can track logs even for retries. You don't have to do anything extra.

### Sentry
Sentry integration is hardcoded inside gem. So when you add anything inside context of Xyeger, it also means that you add something to Sentry context.

### Plain ruby app
For plain ruby application you have implement several steps:

```ruby
# Configure your Xyeger
Xyeger.configure {}

# Create instance of some logger
logger = Logger.new(STDOUT)

# Extend your logger with Xyeger::Logger
logger.extend(Xyeger::Logger)

# You are ready to go
logger.info('Some message')
```



## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

