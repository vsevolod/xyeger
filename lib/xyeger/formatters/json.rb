require 'json'

module Xyeger
  module Formatters
    class Json < Base
      def call(*args)
        result = super(*args)
        result.compact.to_json + "\n"
      end
    end
  end
end
