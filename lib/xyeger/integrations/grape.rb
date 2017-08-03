require 'grape'

module Xyeger
  module GrapeLogger
    included do
      logger.extend(Xyeger::Logger)
      logger.formatter = Xyeger.config.formatter
    end
  end
end
