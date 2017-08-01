module Xyeger
  class ContextResolver
    def call(value)
      case value
      when Hash
        value
      when ::StandardError
        { class: value.class.name, error: value.to_s }
      else
        {}
      end
    end
  end
end
