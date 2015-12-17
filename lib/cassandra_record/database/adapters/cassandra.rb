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
          rescue_with_reset_and_retry do
            session.prepare(cql)
          end
        end

        def execute(cql, opts={})
          rescue_with_reset_and_retry do
            results = session.execute(cql, opts)
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

        def rescue_with_reset_and_retry
          retry_count = 0
          begin
            yield
          rescue ::Cassandra::Error
            if (retry_count += 1) < MAX_RETRIES
              reset_session
              sleep(0.5)
              retry
            else
              raise
            end
          end
        end

        def reset_session
          @session = nil
        end

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
