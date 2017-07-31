require 'active_support/logger'
require 'active_support/tagged_logging'
require 'active_support/dependencies/autoload'
require 'active_support/ordered_options'
require 'xyeger/version'

module Xyeger
  module_function

  extend ActiveSupport::Autoload

  autoload :Config
  autoload :Logger
  autoload :Formatters

  class << self
    attr_reader :config

    def configure
      @config ||= Xyeger::Config.new

      yield(@config)

      if @config.filter_parameters
        @config.filter ||= ActionDispatch::Http::ParameterFilter.new(@config.filter_parameters)
      end
      Rails.logger.extend(Logger)
    end
  end
end
