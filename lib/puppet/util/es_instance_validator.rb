require 'socket'
require 'timeout'

module Puppet
  module Util
    class EsInstanceValidator
      attr_reader :instance_server
      attr_reader :instance_port

      def initialize(instance_server, instance_port)
        @instance_server = instance_server
        @instance_port   = instance_port
      end

      # Utility method; attempts to make an https connection to the Elasticsearch instance.
      # This is abstracted out into a method so that it can be called multiple times
      # for retry attempts.
      #
      # @return true if the connection is successful, false otherwise.
      def attempt_connection
        Timeout.timeout(Puppet[:configtimeout]) do
          begin
            TCPSocket.new(@instance_server, @instance_port).close
            true
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
            Puppet.debug "Unable to connect to Elasticsearch instance (#{@instance_server}:#{@instance_port}): #{e.message}"
            false
          end
        end
      rescue Timeout::Error
        false
      end
    end
  end
end
