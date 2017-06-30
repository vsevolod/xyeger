module Xyeger
  module Formatters
    class Json < ActiveSupport::Logger::SimpleFormatter
      def call(severity, timestamp, context, message)
        message, context = prepare(message, context)

        {
          logger: ENV.fetch('LOGGER_HOSTNAME', $0),
          pid: $$,
          app: Rails.application.class.parent_name,
          env: Rails.env,
          level: severity,
          time: timestamp,
          caller: caller_message(caller_locations),
          message: message,
          context: context
        }.to_json + "\n"
      end

      def caller_message(callers)
        if location = callers.find{|x| x.path.include?(Rails.root.to_s)}
          "#{location.path}:#{location.lineno}"
        end
      end

      def prepare(message, context)
        case message
        when LogrageRaw
          ['Lograge', message.data]
        when ::StandardError
          ['StandardError', { class: message.class.name, error: message.to_s }]
        else
          [message.to_s, context]
        end
      end
    end
  end
end
