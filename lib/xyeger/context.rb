module Xyeger
  class Context
    def initialize
      Thread.current[:xyeger_context] = {}
    end

    def add_context(context = nil)
      context = Xyeger.config.context_resolver.call(context)
      Thread.current[:xyeger_context].merge!(context || {})
    end

    def clear_context
      Thread.current[:xyeger_context] = {}
    end

    def to_hash
      Thread.current[:xyeger_context]
    end
  end
end
