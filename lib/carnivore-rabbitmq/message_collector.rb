module Carnivore
  class Source
    class Rabbitmq
      # Message collector
      class MessageCollector

        include Celluloid
        include Carnivore::Utils::Logging

        # @return [Bunny::Queue, MarchHare::Queue] remote queue
        attr_reader :queue
        # @return [Queue] local message bucket
        attr_reader :message_queue
        # @return [Celluloid::Actor] actor to notify
        attr_reader :notify

        # Create new instance
        #
        # @param queue [Bunny::Queue, MarchHare::Queue] remote queue
        # @param message_queue [Queue] local message bucket
        # @param notify [Celluloid::Actor] actor to notify
        def initialize(queue, message_queue, notify)
          @queue = queue
          @message_queue = message_queue
          @notify = notify
        end

        # Collect messages from remote queue
        #
        # @return [TrueClass]
        def collect_messages
          queue.subscribe(:block => true, :ack => true) do |info, metadata, payload|
            debug "Message received: #{payload.inspect}"
            debug "Message info: #{info.inspect}"
            debug "Message metadata: #{metadata.inspect}"
            message_queue << {:info => info, :metadata => metadata, :payload => payload}
            notify.signal(:new_messages)
          end
          true
        end

      end
    end
  end
end
