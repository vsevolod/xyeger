module Xyeger
  module Formatters
    extend ActiveSupport::Autoload

    autoload :Base
    autoload :Json
    autoload :Values
    autoload :LogrageRaw
    autoload :SidekiqJson
  end
end
