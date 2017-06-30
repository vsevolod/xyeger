module Xyeger
  class Logger < ActiveSupport::Logger
    def initialize(*args)
      super
      @formatter = Formatters::Json.new
    end

    Logger::Severity.constants.each do |severity|
      define_method "#{severity.downcase}" do |message, context={}|
        add(Logger::Severity.const_get(severity), message, context)
      end
    end
  end
end
