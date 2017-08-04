module Xyeger
  module Logger
    def self.extended(base)
      base.formatter = Xyeger.config.formatter
    end

    def add(severity, message = '', progname = nil)
      message = Xyeger.config.message_resolver.call(message, progname)
      super(severity, message, Xyeger.context.current)
    end
  end
end
