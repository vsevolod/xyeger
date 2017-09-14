require 'json'

module Xyeger
  module Puma
    class Event
      extend Forwardable

      attr :io

      def_delegator :@io, :sync=

      def initialize(io)
        @io = io
      end

      def puts(str)
        super(prepare(str))
      end

      def write(str)
        super(prepare(str))
      end

      private

      def prepare(str)
        {
          hostname: ENV['XYEGER_HOSTNAME'] || '',
          pid: $$,
          app: ENV['XYEGER_APPNAME'] || '',
          env: ENV['RAILS_ENV'] || '',
          level: 'INFO',
          time: Time.now,
          message: str,
          context: {}
        }.to_json
      end
    end

    extend self

    def events
      ::Puma::Events.new(stdout, stderr)
    end

    def stdout
      Event.new(STDOUT)
    end

    def stderr
      Event.new(STDERR)
    end
  end
end
