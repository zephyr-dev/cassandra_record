require 'rubygems'

require 'cassandra_record/base'
require 'cassandra_record/statement'
require 'cassandra_record/database/adapters/cassandra'

module CassandraRecord
  Base.configure do |configuration|
    configuration.database_adapter = Database::Adapters::Cassandra.instance
  end
end
