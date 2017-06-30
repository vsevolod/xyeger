module Xyeger
  module Formatters
    class KeyValue < Base
      def call(*args)
        result = super(*args)

        result.compact.to_json + "\n"
      end
    end
  end
end
