module Xyeger
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
end
