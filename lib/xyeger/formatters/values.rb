module Xyeger
  module Formatters
    class Values < Base
      def call(*args)
        result = super(*args)

        result.values.join(' ') + "\n"
      end
    end
  end
end
