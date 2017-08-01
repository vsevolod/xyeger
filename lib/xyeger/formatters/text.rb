module Xyeger
  module Formatters
    class Text < Base
      def call(*args)
        result = super(*args)
        arr = []
        arr << "[#{result[:time]}]"
        arr << "[#{result[:level]}]".ljust(8)

        context = result[:context]
        arr << "[#{context[:fid]}] " if context[:fid]

        arr << context.except(:fid).map { |k, v| "#{k}=#{v}" }.join(' ')
        arr << result[:message]

        "#{arr.join(' ').gsub(/ +/, ' ')}\n"
      end
    end
  end
end
