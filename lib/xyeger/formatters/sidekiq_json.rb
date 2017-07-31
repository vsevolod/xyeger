module Xyeger
  module Formatters
    class SidekiqJson < Base
      def call(severity, timestamp, context, message)
        context, message = prepare_message(message) unless context

        super(severity, timestamp, context, message).merge(
          tid: "TID-#{Thread.current.object_id.to_s(36)}",
          sidekiq_context: sidekiq_context
        ).to_json + "\n"
      end

      def sidekiq_context
        c = Thread.current[:sidekiq_context]
        c.join(' ') if c&.any?
      end

      def prepare_message(message)
        json = JSON.parse(message)
        [filter_context(json), 'Sidekiq']
      rescue JSON::ParserError
        [nil, message]
      end
    end
  end
end
