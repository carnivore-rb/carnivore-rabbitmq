require 'bunny'
require 'carnivore/source'

module Carnivore
  class Source
    class Rabbitmq < Source

      attr_reader :args, :connection, :channel, :queue, :exchange, :queue, :message_queue, :message_collector

      trap_exit :collector_failure

      def setup(args={})
        require 'carnivore-rabbitmq/message_collector'
        @args = args.dup
        @message_queue = Queue.new
        @connection_args = args[:bunny]
        @queue_name = args[:queue]
        @exchange_name = args[:exchange]
        @notifier = Celluloid::Signals.new
        debug "Creating Rabbitmq source instance <#{name}>"
      end

      def connect
        establish_connection
        start_collector
      end

      def start_collector
        @message_collector = MessageCollector.new(queue, message_queue, current_actor)
        self.link message_collector
        message_collector.async.collect_messages
      end

      def collector_failure(collector, reason)
        if(reason)
          error "Message collector unexpectedly failed: #{reason} (restarting)"
          start_collector
        end
      end

      def establish_connection
        @connection = Bunny.new(args[:bunny])
        connection.start
        @channel = connection.create_channel
        @exchange = channel.topic(args[:exchange])
        @queue = channel.queue(args[:queue], :auto_delete => false).bind(exchange) # TODO: Add topic key
      end

      def receive(*_)
        while(message_queue.empty?)
          wait(:new_messages)
        end
        message_queue.pop
      end

      def transmit(payload, *_)
        payload = MultiJson.dump(payload) unless payload.is_a?(String)
        queue.publish(payload)
      end

      def confirm(message)
        info "Confirming message #{message}"
        channel.acknowledge(message[:message][:info].delivery_tag, false)
      end

    end
  end
end
