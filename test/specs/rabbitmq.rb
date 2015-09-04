require 'carnivore-rabbitmq'

def generate_name(prefix)
  "#{prefix}-#{Carnivore.uuid}"
end

describe Carnivore::Source::Rabbitmq do

  describe 'Building a Rabbitmq based source' do

    it 'returns the source' do
      Carnivore::Source.build(
        :type => :rabbitmq,
        :args => {
          :name => :rabbitmq_source,
          :connection => {
            :host => ENV.fetch('CARNIVORE_RABBIT_HOST', '127.0.0.1'),
            :port => ENV.fetch('CARNIVORE_RABBIT_PORT', 5672),
            :username => ENV.fetch('CARNIVORE_RABBIT_USERNAME', 'guest'),
            :password => ENV.fetch('CARNIVORE_RABBIT_PASSWORD', 'guest')
          },
          :queue => generate_name(:queue),
          :exchange => generate_name(:exchange)
        }
      )
      t = Thread.new{ Carnivore.start! }
      source_wait
      Carnivore::Supervisor.supervisor[:rabbitmq_source].name.wont_be_nil
      t.terminate
      Carnivore::Supervisor.supervisor.terminate
    end

  end

  describe 'Rabbitmq source based communication' do
    before do
      @source1 = []
      @source2 = []
      MessageStore.init
      Carnivore::Source.build(
        :type => :rabbitmq,
        :args => {
          :name => :rabbitmq_source,
          :connection => {
            :host => ENV.fetch('CARNIVORE_RABBIT_HOST', '127.0.0.1'),
            :port => ENV.fetch('CARNIVORE_RABBIT_PORT', 5672),
            :username => ENV.fetch('CARNIVORE_RABBIT_USERNAME', 'guest'),
            :password => ENV.fetch('CARNIVORE_RABBIT_PASSWORD', 'guest')
          },
          :queue => generate_name(:queue),
          :exchange => generate_name(:exchange)
        }
      ).add_callback(:store) do |message|
        MessageStore.messages.push(message[:content])
      end
      @runner = Thread.new{ Carnivore.start! }
      source_wait do
        Carnivore::Supervisor.supervisor &&
          Carnivore::Supervisor.supervisor.alive? &&
          !Carnivore::Supervisor.supervisor[:rabbitmq_source].nil?
      end
    end

    after do
      @runner.terminate
      Carnivore::Supervisor.supervisor.terminate
    end

    describe 'message transmissions' do
      it 'should accept message transmits' do
        Carnivore::Supervisor.supervisor[:rabbitmq_source].transmit('test message')
      end

      it 'should receive messages' do
        Carnivore::Supervisor.supervisor[:rabbitmq_source].transmit('test message 2')
        source_wait{ MessageStore.messages.include?('test message 2') }
        MessageStore.messages.must_include 'test message 2'
      end
    end
  end

end
