module Xyeger
  module Formatters
    class Base
      UNCOLORIZE_REGEXP = /\e\[([;\d]+)?m/

      attr_reader :attributes, :colors

      def initialize(attributes = {})
        @attributes = attributes
        @colors = Array.new(9) { Paint.random } if attributes[:colored]
      end

      def call(severity, timestamp, context, message)
        message, context = prepare(message, context)

        context = filter_context(context)

        result = {
          hostname: Xyeger.config.hostname,
          pid: $$,
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
        message = uncolorize(message) unless attributes[:colored]

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

      private def filter_context(context)
        return context unless Xyeger.config.filter && context.is_a?(Hash)

        Xyeger.config.filter.filter(context)
      end

      def uncolorize(message)
        message.gsub(UNCOLORIZE_REGEXP, '')
      end
    end
  end
end
