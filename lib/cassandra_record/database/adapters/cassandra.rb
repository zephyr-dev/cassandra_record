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
          session.prepare(cql)
        end

        def execute(cql, *args)
          session.execute(cql, *args)
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
