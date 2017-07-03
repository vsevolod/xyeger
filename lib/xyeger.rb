require 'active_support/logger'
require 'active_support/dependencies/autoload'
require 'active_support/ordered_options'
require 'paint'
require 'lograge'
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
      @config ||= Xyeger::Config.new()

      yield(@config)

      if @config.filter_parameters
        @config.filter ||= ActionDispatch::Http::ParameterFilter.new(@config.filter_parameters)
      end
      Xyeger.setup
    end
  end

  def setup
    app = Rails.application
    setup_lograge(app)

    app.config.logger = Logger.new(config.output)
    Rails.logger = app.config.logger
    Rails.logger.formatter = config.formatter
  end

  def setup_lograge(app)
    app.config.lograge.formatter = -> (data) { Formatters::LogrageRaw.new(data: data) }
    app.config.lograge.custom_options = lambda do |event|
      { params: event.payload[:params]&.except('controller', 'action', 'format', 'id') }
    end

    Lograge.setup(app)
  end
end
