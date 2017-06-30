module Xyeger
  class Logger < ActiveSupport::Logger
    Logger::Severity.constants.each do |severity|
      define_method "#{severity.downcase}" do |message, context={}|
        add(Logger::Severity.const_get(severity), message, context)
      end
    end
  end
end
