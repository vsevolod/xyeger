module Xyeger
  class MessageResolver
    def self.call(message, progname)
      message =
        case message
        when ::StandardError
          [message.class.name, message].compact.join(' ')
        else
          message.to_s
        end
      [progname, message].compact.join(' ')
    end
  end
end
