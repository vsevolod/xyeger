module Xyeger
  module Formatters
    class Base
      attr_reader :attributes, :colors

      def initialize(attributes = {})
        @attributes = attributes
        @colors = Array.new(9) { Paint.random } if attributes[:colored]
      end

      def call(severity, timestamp, context, message)
        message, context = prepare(message, context)

        context = Xyeger.config.filter.filter(context) if Xyeger.config.filter

        result = {
          hostname: Xyeger.config.hostname,
          pid: Xyeger.config.pid,
          app: Xyeger.config.app,
          env: Xyeger.config.env,
          level: severity,
          time: timestamp,
          caller: caller_message(caller_locations),
          message: message,
          context: context
        }

        colored(result) if attributes[:colored]

        result
      end

      private def caller_message(callers)
        if location = callers.find{|x| x.path.include?(Rails.root.to_s)}
          "#{location.path}:#{location.lineno}"
        end
      end

      private def prepare(message, context)
        new_message = attributes[:message].call(message, context) if attributes[:message]
        new_context = attributes[:context].call(message, context) if attributes[:context]

        return [new_message, new_context] if attributes[:message] || attributes[:context]

        case message
        when LogrageRaw
          ['Lograge', message.data]
        when ::StandardError
          ['StandardError', { class: message.class.name, error: message.to_s }]
        else
          [message.to_s, context]
        end
      end

      private def colored(result)
        result.each_with_index do |(key, value), index|
          result[key] = Paint[value, colors[index]]
        end
      end
    end
  end
end
