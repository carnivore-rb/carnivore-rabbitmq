module Carnivore
  class Source
    class Rabbitmq
      class MessageCollector

        include Celluloid
        include Carnivore::Utils::Logging

        attr_reader :queue, :message_queue, :notify

        def initialize(queue, message_queue, notify)
          @queue = queue
          @message_queue = message_queue
          @notify = notify
        end

        def collect_messages
          queue.subscribe(:block => true, :ack => true) do |info, metadata, payload|
            debug "Message received: #{payload.inspect}"
            debug "Message info: #{info.inspect}"
            debug "Message metadata: #{metadata.inspect}"
            message_queue << {:info => info, :metadata => metadata, :payload => payload}
            notify.signal(:new_messages)
          end
        end

      end
    end
  end
end
