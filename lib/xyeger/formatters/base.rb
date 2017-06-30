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

        result = {
          logger: ENV['XYEGER_HOSTNAME'],
          pid: $$,
          app: Rails.application.class.parent_name,
          env: Rails.env,
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
