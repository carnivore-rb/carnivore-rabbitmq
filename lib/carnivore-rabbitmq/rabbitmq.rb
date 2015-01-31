require 'carnivore-rabbitmq'

module Carnivore
  class Source

    # RabbitMQ based carnivore source
    class Rabbitmq < Source

      autoload :MessageCollector, 'carnivore-rabbitmq/message_collector'

      # @return [Smash] initialization arguments
      attr_reader :args
      # @return [MarchHare::Session, Bunny::Session] current connection
      attr_reader :connection
      # @return [MarchHare::Exchange, Bunny::Exchange] current exchange
      attr_reader :exchange
      # @return [MarchHare::Channel, Bunny::Channel] current channel
      attr_reader :channel
      # @return [MarchHare::Queue, Bunny::Queue] current queue
      attr_reader :queue
      # @return [String] routing key
      attr_reader :routing_key
      # @return [Queue] message queue
      attr_reader :message_queue
      # @return [Carnviore::Source::Rabbitmq::MessageCollector] message collector
      attr_reader :message_collector

      trap_exit :collector_failure
      finalizer :collector_teardown

      # RabbitMQ source setup
      #
      # @param init_args [Hash] initialization configuration
      # @option init_args [String] :queue name of queue
      # @option init_args [String] :exchange name of exchange
      # @option init_args [Hash] :connection configuration hash for connection
      # @option init_args [String, Symbol] :force_library :bunny or :march_hare
      def setup(init_args={})
        require 'carnivore-rabbitmq/message_collector'
        @args = args.dup
        @message_queue = Queue.new
        @queue_name = args[:queue]
        @exchange_name = args[:exchange]
        debug "Creating Rabbitmq source instance <#{name}>"
      end

      # Connect to the remote server
      def connect
        establish_connection
      end

      # Start the message collection
      def start_collector
        unless(@collecting)
          @collecting = true
          @message_collector = MessageCollector.new(queue, message_queue, current_actor)
          self.link message_collector
          message_collector.async.collect_messages
        end
      end

      # Restart collector if unexpectedly failed
      #
      # @param object [Actor] crashed actor
      # @param reason [Exception, NilClass]
      def collector_failure(object, reason)
        if(reason && object == message_collector)
          error "Message collector unexpectedly failed: #{reason} (restarting)"
          start_collector
        end
      end

      # Destroy message collector
      #
      # @return [TrueClass]
      def collector_teardown
        connection.close if connection
        if(message_collector && message_collector.alive?)
          message_collector.terminate
        end
        true
      end

      # Establish connection to remote server and setup
      #
      # @return [MarchHare::Session, Bunny::Session]
      def establish_connection
        unless(args[:connection])
          abort KeyError.new "No configuration defined for connection type (#{connection_library})"
        end
        connection_args = Carnivore::Utils.symbolize_hash(args[:connection])
        case connection_library
        when :bunny
          require 'bunny'
          @connection = Bunny.new(connection_args)
        when :march_hare
          require 'march_hare'
          @connection = MarchHare.new(connection_args)
        else
          abort ArgumentError.new("No valid connection arguments defined (:bunny or :march_hare must be defined)")
        end
        connection.start
        @routing_key = args[:routing_key]
        @channel = connection.create_channel
        @exchange = channel.topic(args[:exchange])
        @queue = channel.queue(args[:queue], :auto_delete => false).
          bind(exchange, :routing_key => routing_key)
        @connection
      end

      # Receive payload from connection
      #
      # @return [Hash] payload
      def receive(*_)
        start_collector
        while(message_queue.empty?)
          wait(:new_messages)
        end
        message_queue.pop
      end

      # Transmit payload to connection
      #
      # @param payload [Object]
      def transmit(payload, *_)
        payload = MultiJson.dump(payload) unless payload.is_a?(String)
        if(args[:publish_via].to_s == 'exchange')
          exchange.publish(payload, :routing_key => routing_key)
        else
          queue.publish(payload, :routing_key => routing_key)
        end
      end

      # Confirm message processing
      #
      # @param message [Carnivore::Message]
      def confirm(message)
        info "Confirming message #{message}"
        channel.acknowledge(message[:message][:info].delivery_tag, false)
      end

      # @return [Symbol] connection library to utilize
      def connection_library
        if(args[:force_library])
          args[:force_library].to_sym
        else
          RUBY_PLATFORM == 'java' ? :march_hare : :bunny
        end
      end

    end
  end
end
