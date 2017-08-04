module Xyeger
  module Middlewares
    class ClearContext
      def initialize(app)
        @app = app
      end

      def call(env)
        puts 'inside Clear context'
        @app.call(env)
      ensure
        puts 'going to clear context'
        Xyeger.clear_context
        puts 'context cleared'
      end
    end
  end
end
