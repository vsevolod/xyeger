require 'sidekiq'

module Xyeger
  module Sidekiq
    module LoggingPatch
      def with_job_hash_context(job_hash)
        # If we're using a wrapper class, like ActiveJob, use the 'wrapped'
        # attribute to expose the underlying thing.
        klass = job_hash['wrapped'] || job_hash['class']
        jid = job_hash['jid']
        fid = job_hash['fid'] || Xyeger.context.current[:fid] || SecureRandom.uuid

        Xyeger.add_context(worker: klass, fid: fid, jid: jid)

        yield
      ensure
        Xyeger.clear_context
      end
    end

    class FlowIdMiddleware
      def call(_worker_class, msg, _queue, _redis_pool)
        msg['fid'] = Xyeger.context.current[:fid]
        yield
      end
    end
  end
end

::Sidekiq.logger = Rails.logger

::Sidekiq::Logging.singleton_class.prepend(Xyeger::Sidekiq::LoggingPatch)

::Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add(Xyeger::Sidekiq::FlowIdMiddleware)
  end
end
