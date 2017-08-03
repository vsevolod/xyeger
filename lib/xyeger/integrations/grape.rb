require 'grape'

module Xyeger
  module Grape
    module Logger
      def self.included(_base)
        ::Grape::API.logger.extend(Xyeger::Logger)
        ::Grape::API.logger.formatter = Xyeger.config.formatter
      end
    end
  end
end
