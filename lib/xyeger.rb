require 'active_support/tagged_logging'
require 'forwardable'
require 'xyeger/version'
require 'xyeger/config'
require 'xyeger/context'
require 'xyeger/context_resolver'
require 'xyeger/message_resolver'
require 'xyeger/formatters'
require 'xyeger/logger'
require 'xyeger/middlewares/clear_context'

module Xyeger
  module_function

  class << self
    attr_reader :config
    extend Forwardable

    def configure
      require 'xyeger/integrations/rails' if defined?(Rails)
      require 'xyeger/integrations/sidekiq' if defined?(Sidekiq)
      require 'xyeger/integrations/grape' if defined?(Grape)
      @config ||= Xyeger::Config.new
      yield(@config)
    end

    def_delegator :config, :context
    def_delegator :context, :add_context
    def_delegator :context, :clear_context
  end
end
