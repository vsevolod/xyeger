require 'spec_helper'

RSpec.describe Xyeger::Logger do
  subject(:logger) { Xyeger::Logger.new(STDOUT) }

  describe '#info' do
    let(:info) { ::Logger::Severity::INFO }
    let(:text) { 'TEST' }
    let(:context) { { context: true } }

    it 'calls with first argument as a message' do
      expect(logger).to receive(:add).with(info, text, nil)

      logger.info(text)
    end

    it 'calls with context and message' do
      expect(logger).to receive(:add).with(info, text, context)

      logger.info('TEST', context)
    end

    it 'calls with block and message' do
      expect(logger).to receive(:add).with(info, text, context)

      logger.info('TEST') { context }
    end

    it 'calls with with hash-block only' do
      expect(logger).to receive(:add).with(info, nil, context)

      logger.info { context }
    end

    it 'calls with with text block only' do
      expect(logger).to receive(:add).with(info, text, nil)

      logger.info { text }
    end
  end
end
