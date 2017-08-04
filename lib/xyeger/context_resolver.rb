module Xyeger
  class ContextResolver
    def self.call(value)
      case value
      when Hash
        value
      else
        {}
      end
    end
  end
end
