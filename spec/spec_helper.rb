ENV['environment'] = 'test'

require 'cassandra_record'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  # create test keyspace and table
  db = CassandraRecord::Database::Adapters::Cassandra.instance

  config.add_setting :db
  config.add_setting :keyspace

  config.db = db
  config.keyspace = 'test_space'  # CassandraRecord::Database::Adapters::Cassandra.instance.keyspace

  create_keyspace = <<-CQL
    CREATE KEYSPACE IF NOT EXISTS #{config.keyspace} WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};
  CQL

  create_test_table_1 = <<-CQL
    CREATE TABLE IF NOT EXISTS test_records (
      id int,
      name text,
      PRIMARY KEY (id)
    );
  CQL

  create_test_table_2 = <<-CQL
    CREATE TABLE IF NOT EXISTS matching_log_items (
      blah int,
      whatever text,
      PRIMARY KEY (blah)
    );
  CQL

  create_test_table_3 = <<-CQL
    CREATE TABLE IF NOT EXISTS non_matching_log_items (
      blah int,
      whatever text,
      PRIMARY KEY (blah)
    );
  CQL

  create_table_index = <<-CQL
    CREATE INDEX IF NOT EXISTS test_records_name_index ON test_records (name);
  CQL

  db.cluster.execute(create_keyspace)
  db.use(config.keyspace)
  db.execute(create_test_table_1)
  db.execute(create_test_table_2)
  db.execute(create_test_table_3)
  db.execute(create_table_index)

  config.before(:each) do
    ['test_records', 'matching_log_items'].each do |table_name|
      db.execute("TRUNCATE #{table_name}")
    end
  end
end
