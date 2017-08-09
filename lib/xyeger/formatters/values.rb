module Xyeger
  module Formatters
    class Values < Base
      def call(*args)
        result = super(*args)

        result.values.join(' ').gsub(/ +/, ' ') + "\n"
      end
    end
  end
end
