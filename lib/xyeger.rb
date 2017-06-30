require 'active_support/logger'
require 'active_support/dependencies/autoload'
require 'active_support/ordered_options'
require 'paint'
require 'lograge'
require "xyeger/version"

module Xyeger
  module_function

  extend ActiveSupport::Autoload

  autoload :Logger
  autoload :Formatters

  def setup(app)
    setup_lograge(app)

    app.config.logger = Logger.new(app.config.xyeger.output)
    Rails.logger = app.config.logger
    Rails.logger.formatter = app.config.xyeger.formatter
  end

  def setup_lograge(app)
    app.config.lograge.formatter = -> (data) { Formatters::LogrageRaw.new(data: data) }
    app.config.lograge.custom_options = lambda do |event|
      { params: event.payload[:params]&.except('controller', 'action', 'format', 'id') }
    end

    Lograge.setup(app)
  end
end

require 'xyeger/railtie' if defined?(Rails)
