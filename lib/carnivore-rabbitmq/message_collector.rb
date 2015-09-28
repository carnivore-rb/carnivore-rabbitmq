require 'carnivore-rabbitmq'

module Carnivore
  class Source
    class Rabbitmq
      # Message collector
      class MessageCollector

        include Zoidberg::SoftShell
        include Zoidberg::Supervise
        include Carnivore::Utils::Logging

        # @return [Bunny::Queue, MarchHare::Queue] remote queue
        attr_reader :queue
        # @return [Celluloid::Actor] actor to notify
        attr_reader :notify

        # Create new instance
        #
        # @param queue [Bunny::Queue, MarchHare::Queue] remote queue
        # @param notify [Zoidberg::Shell] actor to notify
        def initialize(queue, notify)
          @queue = queue
          @notify = notify
        end

        # Start message collection when restarted
        def restarted
          start!
        end

        # Start the collector
        def start!
          current_self.async.collect_messages
        end

        # Collect messages from remote queue
        #
        # @return [TrueClass]
        def collect_messages
          queue.subscribe(:block => true, :manual_ack => true) do |info, metadata, payload|
            if(payload.nil?)
              payload = metadata
              metadata = {}
            end
            begin
              payload = MultiJson.load(payload).to_smash
            rescue MultiJson::ParseError
              debug 'Received payload not in JSON format. Failed to parse!'
            end
            debug "Message received: #{payload.inspect}"
            debug "Message info: #{info.inspect}"
            debug "Message metadata: #{metadata.inspect}"
            new_message = Smash.new(
              :raw => Smash.new(
                :info => info,
                :metadata => metadata
              ),
              :content => payload
            )
            debug "Sending new message signal to: #{notify}"
            notify.signal(:new_messages, new_message)
          end
          true
        end

      end
    end
  end
end
