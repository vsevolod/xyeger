require 'grape'

module Xyeger
  module Grape
    module Logger
      included do
        logger.extend(Xyeger::Logger)
        logger.formatter = Xyeger.config.formatter
      end
    end
  end
end
