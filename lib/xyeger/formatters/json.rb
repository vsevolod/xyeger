require 'json'

module Xyeger
  module Formatters
    class Json < Base
      def call(*args)
        puts args.inspect
        result = super(*args)
        puts result.inspect
        result.compact.to_json + "\n"
      end
    end
  end
end
