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
        puts "#{fid} for context"
        Xyeger.add_context(fid: fid)
        puts "current context: #{Xyeger.context.current}"
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
      ::Rails.logger.extend(Xyeger::Logger)
    end
  end
end
