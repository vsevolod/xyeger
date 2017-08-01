module Xyeger
  module Formatters
    class Base
      include ActiveSupport::TaggedLogging::Formatter

      UNCOLORIZE_REGEXP = /\e\[([;\d]+)?m/

      attr_reader :attributes

      def initialize(attributes = {})
        @attributes = attributes
        @tags = []
      end

      def call(severity, timestamp, context, message)
        message, context = prepare(message, context)
        message = uncolorize(message)
        result = {
          hostname: Xyeger.config.hostname,
          pid: $$, # rubocop:disable Style/SpecialGlobalVars
          app: Xyeger.config.app,
          env: Xyeger.config.env,
          level: severity,
          time: timestamp,
          message: message,
          context: context
        }

        result[:tags] = current_tags if current_tags.any?

        if attributes[:except]&.any?
          result.except(*attributes[:except])
        else
          result
        end
      end

      private def prepare(message, context)
        case message
        when ::StandardError
          ['StandardError', { class: message.class.name, error: message.to_s }]
        else
          [message.to_s, context]
        end
      end

      def uncolorize(message)
        message.to_s.gsub(UNCOLORIZE_REGEXP, '')
      end
    end
  end
end
