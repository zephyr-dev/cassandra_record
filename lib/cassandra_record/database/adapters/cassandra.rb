require 'cassandra'
require 'singleton'

module CassandraRecord
  module Database
    module Adapters
      class Cassandra
        include Singleton

        attr_reader :keyspace

        def session
          @session ||= ::Cassandra.cluster.connect(@keyspace)
        end

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
          ::Cassandra.cluster.connect
        end

        def session
          @session ||= ::Cassandra.cluster.connect(@keyspace)
        end

      end
    end
  end
end
