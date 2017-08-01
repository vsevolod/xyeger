module Xyeger
  class Config
    attr_writer(
      :output, :formatter,
      :app, :env, :hostname,
      :context, :context_resolver
    )

    def output
      @output ||= STDOUT
    end

    def formatter
      @formatter ||= Xyeger::Formatters::Json.new
    end

    def hostname
      @hostname ||= ENV['XYEGER_HOSTNAME']
    end

    def app
      @app ||= ENV['XYEGER_APPNAME']
    end

    def env
      @env ||= ENV['XYEGER_ENV']
    end

    def context
      @context ||= Xyeger::Context.new
    end

    def context_resolver
      @context_resolver ||= Xyeger::ContextResolver.new
    end
  end
end
