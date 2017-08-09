require 'rails'

module Xyeger
  module Rails
    class FlowIdMiddleware
      def initialize(app)
        @app = app
      end

      def call(env)
        request = ActionDispatch::Request.new(env)
        fid = request.request_id || SecureRandom.uuid
        Xyeger.add_context(fid: fid)
        @app.call(env)
      end
    end
  end

  class Railtie < ::Rails::Railtie
    initializer 'xyeger.configure_rails_initialization' do |app|
      app.config.middleware.insert_after(
        ActionDispatch::RequestId, Xyeger::Middlewares::ClearContext
      )
      app.config.middleware.insert_after(
        ActionDispatch::RequestId, Xyeger::Rails::FlowIdMiddleware
      )
    end

    config.after_initialize do
      ::Rails.logger = ActiveSupport::Logger.new(STDOUT)
      ::Rails.logger.extend(Xyeger::Logger)
      ::ActiveSupport.on_load(:action_record) { self.logger = ::Rails.logger }
    end
  end
end
