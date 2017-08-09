module Xyeger
  class Context
    def self.current
      Thread.current[:xyeger_context] ||= {}
    end

    def self.clear_context
      Thread.current[:xyeger_context] = nil
    end

    def self.add_context(context = {})
      return unless context
      context = Xyeger.config.context_resolver.call(context)
      ::Raven.tags_context(context) if defined?(::Raven)
      Thread.current[:xyeger_context] ||= {}
      Thread.current[:xyeger_context].merge!(context || {})
    end
  end
end
