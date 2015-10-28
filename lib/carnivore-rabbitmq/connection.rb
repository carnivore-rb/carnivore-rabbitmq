require 'carnivore-rabbitmq'

module Carnivore
  class Source
    class Rabbitmq
      # RabbitMQ connection
      class Connection

        include Zoidberg::SoftShell
        include Zoidberg::Supervise
        include Carnivore::Utils::Logging

        # @return [Hash]
        attr_reader :source_args
        # @return [String]
        attr_reader :routing_key
        # @return [Bunny::Connection, MarchHare::Connection]
        attr_reader :connection
        # @return [Bunny::Channel, MarchHare::Channel]
        attr_reader :channel
        # @return [Bunny::Exchange, MarchHare::Exchange]
        attr_reader :exchange
        # @return [Bunny::Queue, MarchHare::Queue]
        attr_reader :queue
        # @return [Carnivore::Source::Rabbitmq]
        attr_reader :source
        # @return [Queue]
        attr_reader :message_queue
        # @return [Signal]
        attr_reader :source_signal

        # Create new connection
        #
        # @param r_source [Carnivore::Source::Rabbitmq] origin
        # @param m_queue [Queue] common message queue
        # @return [self]
        def initialize(r_source, m_queue)
          @source = r_source
          @source_args = r_source.args.to_smash
          @message_queue = m_queue
          connect
        end

        # Restart trigger for supervised replacements
        def restarted
          connect
          if(source.collect_messages)
            async.receive_messages
          end
        end

        # Close down the connection if available
        def terminate
          if(connection)
            connection.close
          end
        end

        # Establish connection to remote server and setup
        #
        # @return [MarchHare::Session, Bunny::Session]
        def connect
          unless(source_args[:connection])
            abort KeyError.new "No configuration defined for connection type (#{connection_library})"
          end
          connection_args = Carnivore::Utils.symbolize_hash(source_args[:connection])
          case connection_library
          when :bunny
            require 'bunny'
            @connection = Bunny.new(connection_args)
          when :march_hare
            require 'march_hare'
            @connection = MarchHare.connect(connection_args)
          else
            abort ArgumentError.new("No valid connection arguments defined (:bunny or :march_hare must be defined)")
          end
          connection.start
          @routing_key = source_args[:routing_key]
          @channel = connection.create_channel
          @exchange = channel.topic(source_args[:exchange])
          @queue = channel.queue(source_args[:queue], :auto_delete => false).
            bind(exchange, :routing_key => routing_key)
          @connection
        end

        # Write message to connection
        #
        # @param payload [String]
        def write(payload)
          if(source_args[:publish_via].to_s == 'exchange')
            exchange.publish(payload, :routing_key => routing_key)
          else
            queue.publish(payload, :routing_key => routing_key)
          end
        end

        # Send message acknowledgement
        #
        # @param tag [String]
        def ack(tag)
          channel.acknowledge(tag, false)
        end

        # Start receiving message
        def receive_messages
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
            new_message = Smash.new(
              :raw => Smash.new(
                :info => info,
                :metadata => metadata
              ),
              :content => payload
            )
            debug "<#{source}> New message: #{new_message}"
            source.signal(:new_message, new_message)
            wait(:ready)
          end
          true
        end

        # @return [Symbol] connection library to utilize
        def connection_library
          if(source_args[:force_library])
            source_args[:force_library].to_sym
          else
            RUBY_PLATFORM == 'java' ? :march_hare : :bunny
          end
        end

      end
    end
  end
end
