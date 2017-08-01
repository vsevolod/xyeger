module Xyeger
  module Formatters
    class Text < Base
      def call(*args)
        hash = super(*args)
        arr = []
        arr << "[#{hash[:time]}]"
        arr << "[#{hash[:level]}]".ljust(8)

        context = args[:context]
        arr << "[#{fid}] " if context[:fid]

        arr << context.except(:fid).map { |k, v| "#{k}=#{v}" }.join(' ')
        arr << message.to_s if message

        "#{arr.join(' ')}\n"
      end
    end
  end
end
