require 'cassandra'
require 'singleton'
require 'active_support/hash_with_indifferent_access'

module CassandraRecord
  module Database
    module Adapters
      class Cassandra
        include Singleton

        attr_reader :keyspace

        def use(keyspace_name)
          @session = nil
          @keyspace = keyspace_name
        end

        def prepare(cql)
          retry_count = 0
          begin
            session.prepare(cql)
          rescue ::Cassandra::Error
            if (retry_count += 1) < MAX_RETRIES
              @session = nil
              session.prepare(cql)
            end
          end
        end

        def execute(cql, *args)
          retry_count = 0
          begin
            session.execute(cql, arguments: args)
          rescue ::Cassandra::Error
            if (retry_count += 1) < MAX_RETRIES
              @session = nil
              session.execute(cql, arguments: args)
            end
          end
        end

        def cluster
          cluster_connection.connect
        end

        def session
          @session ||= cluster_connection.connect(@keyspace)
        end

        def configuration(&block)
          yield(connection_configuration) if block_given?
          connection_configuration
        end

        private

        MAX_RETRIES = 4

        def cluster_connection
          ::Cassandra.cluster(connection_configuration.symbolize_keys)
        end

        def connection_configuration
          @connection_configuration ||= {}
        end

      end
    end
  end
end
