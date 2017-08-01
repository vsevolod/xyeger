module Xyeger
  module Logger
    def add(severity, message = '', context = {})
      Xyeger.add_context(context)
      if message.is_a?(Hash)
        Xyeger.add_context(message)
        message = ''
      end
      context = Xyeger.context.to_hash
      super(severity, message, context)
    end
  end
end
