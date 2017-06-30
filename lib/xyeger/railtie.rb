require 'rails/railtie'
require 'action_view/log_subscriber'
require 'action_controller/log_subscriber'

module Xyeger
  class Raitie < Rails::Railtie
    config.xyeger = ActiveSupport::OrderedOptions.new
    config.xyeger.enabled = false
    config.xyeger.output = STDOUT

    config.after_initialize do |app|
      Xyeger.setup(app) if app.config.xyeger.enabled
    end
  end
end
