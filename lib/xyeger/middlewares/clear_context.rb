module Xyeger
  module Middlewares
    class ClearContext
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call(env)
      ensure
        Xyeger.clear_context
      end
    end
  end
end
