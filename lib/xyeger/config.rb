module Xyeger
  class Config
    attr_accessor :output, :formatter, :hostname, :app, :env, :context, :context_resolver

    def initialize
      @output = STDOUT
      @formatter = Xyeger::Formatters::Json.new
      @hostname = ENV['XYEGER_HOSTNAME']
      @app = ENV['XYEGER_APPNAME']
      @env = ENV['XYEGER_ENV']
      @context = Xyeger::Context.new
      @context_resolver = Xyeger::ContextResolver.new
    end
  end
end
