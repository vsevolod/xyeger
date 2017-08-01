module Xyeger
  module Logger
    def self.extended(base)
      base.formatter = Xyeger.config.formatter
    end

    def add(severity, message = nil, progname = nil, &block)
      message = prepare(message, progname, &block)
      super(severity, message, Xyeger.context.current)
    end

    def prepare(message, progname, &block)
      if message.nil?
        if block_given?
          message = yield(block)
        else
          message = progname
          progname = nil
        end
      end
      Xyeger.config.message_resolver.call(message, progname)
    end
  end
end
