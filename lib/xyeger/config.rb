module Xyeger
  class Config
    attr_accessor :output, :formatter, :hostname, :app, :env, :context_resolver, :message_resolver
    attr_reader :context

    def initialize
      @output = STDOUT
      @formatter = Xyeger::Formatters::Json.new
      @hostname = ENV['XYEGER_HOSTNAME'] || ''
      @app = ENV['XYEGER_APPNAME'] || ''
      @env = ENV['XYEGER_ENV'] || ''
      @context = Xyeger::Context
      @context_resolver = Xyeger::ContextResolver
      @message_resolver = Xyeger::MessageResolver
    end
  end
end
