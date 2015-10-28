require 'carnivore-rabbitmq'

module Carnivore
  class Source

    # RabbitMQ based carnivore source
    class Rabbitmq < Source

      option :cache_signals

      autoload :Connection, 'carnivore-rabbitmq/connection'

      # @return [Smash] initialization arguments
      attr_reader :args
      # @return [Connection] current connection
      attr_reader :connection
      # @return [Queue]
      attr_reader :message_queue
      # @return [TrueClass, FalseClass]
      attr_reader :collect_messages

      # RabbitMQ source setup
      #
      # @param init_args [Hash] initialization configuration
      # @option init_args [String] :queue name of queue
      # @option init_args [String] :exchange name of exchange
      # @option init_args [Hash] :connection configuration hash for connection
      # @option init_args [String, Symbol] :force_library :bunny or :march_hare
      def setup(init_args={})
        @args = args.dup
        @message_queue = Queue.new
        debug "Creating Rabbitmq source instance <#{name}>"
      end

      # Connect to the remote server
      def connect
        @connection = Connection.new(current_self, message_queue)
      end

      # Destroy message collector
      #
      # @return [TrueClass]
      def terminate
        connection.terminate if connection
        super
      end

      # Receive payload from connection
      #
      # @return [Hash] payload
      def receive(*_)
        unless(collect_messages)
          @collect_messages = true
          connection.async.receive_messages
        end
        connection.signal(:ready)
        wait(:new_message)
      end

      # Transmit payload to connection
      #
      # @param payload [Object]
      def transmit(payload, *_)
        defer do
          payload = MultiJson.dump(payload) unless payload.is_a?(String)
          connection.write(payload)
        end
      end

      # Confirm message processing
      #
      # @param message [Carnivore::Message]
      def confirm(message)
        defer do
          info "Confirming message #{message}"
          connection.ack(message[:message][:info].delivery_tag)
        end
      end

    end
  end
end
