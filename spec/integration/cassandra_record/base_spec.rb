require 'spec_helper'

describe CassandraRecord::Base do
  let(:db) { RSpec.configuration.db }
  let(:keyspace)  { RSpec.configuration.keyspace }

  before do
    CassandraRecord::Base.configure do |configuration|
      configuration.database_adapter = ::CassandraRecord::Database::Adapters::Cassandra.instance
    end
  end

  class TestRecord < CassandraRecord::Base; end

  describe ".create" do
    it "returns a hydrated record" do
      record = TestRecord.create(id: 99, name: 'turkey')

      expect(record.id).to eq(99)
      expect(record.name).to eq('turkey')
    end

    it "persists a record" do
      record = TestRecord.create(id: 99, name: 'turkey')

      select = <<-CQL
      SELECT * from #{keyspace}.test_records
      WHERE id = 99;
      CQL

      results = db.execute(select)
      expect(results.count).to eq(1)

      result = results.first
      expect(result['id']).to eq(99)
      expect(result['name']).to eq('turkey')
    end

    context "with TTL options" do
      class TestRecord < CassandraRecord::Base
        def create
          options = { ttl: 1 }
          super(options)
        end
      end

      it "persists a record" do
        TestRecord.create(id: 300, name: 'I\'m going away')

        select = <<-CQL
        SELECT * from #{keyspace}.test_records
        WHERE id = 300;
        CQL

        results = db.execute(select)
        expect(results.count).to eq(1)

        # sucky, but we need to wait for Cassandra
        # to remove the record to assert the TTL is working
        sleep 1

        results = db.execute(select)
        expect(results.count).to eq(0)
      end
    end
  end

  describe ".batch_create" do
    context "with TTL options" do
      it "persists a record" do
        TestRecord.batch_create([{ id: 99, name: 'turkey' }, { id: 100, name: 'buffalo' }], ttl: 1)

        select = <<-CQL
        SELECT * from #{keyspace}.test_records
        CQL

        results = db.execute(select)
        expect(results.count).to eq 2

        sleep 2

        results = db.execute(select)
        expect(results.count).to eq 0
      end
    end

    it "returns an array of the records it created" do
      records = TestRecord.batch_create([{ id: 99, name: 'turkey' }, { id: 100, name: 'buffalo' }])
      expect(records.first.name).to eq "turkey"
      expect(records.last.name).to eq "buffalo"
    end

    it "persists the records" do
      TestRecord.batch_create([{ id: 99, name: 'turkey' }, { id: 100, name: 'buffalo' }])

      select = <<-CQL
      SELECT * from #{keyspace}.test_records
      CQL

      results = db.execute(select)
      expect(results.count).to eq 2
      expect(results.first['id']).to eq 99
    end
  end

  describe ".all" do
    let(:insert_1) { [9090, 'burgers'] }
    let(:insert_2) { [8080, 'hot dogs'] }
    let(:insert_3) { [7070, 'spaghetti'] }
    let(:insert_4) { [6060, 'tacos'] }
    let(:insert_5) { [5050, 'birthday cake'] }

    let(:inserts) do
      [ insert_1,
        insert_2,
        insert_3,
        insert_4,
        insert_5
      ]
    end

    before do
      inserts.each do |record|
        insert_statement = <<-CQL
          INSERT INTO #{keyspace}.test_records (id, name)
          VALUES (#{record[0]}, '#{record[1]}');
        CQL
        db.execute(insert_statement)
      end
    end

    it "combines results from all pages into a single result set" do
      results = TestRecord.where(page_size: 2)
      expect(results.count).to eq(5)

      results.each do |result|
        expect(inserts).to include([result.id, result.name])
      end
    end
  end

  describe ".where" do
    context "with results" do
      let(:insert_1) { [9090, 'burgers'] }
      let(:insert_2) { [8080, 'nachos'] }
      let(:insert_3) { [7070, 'nachos'] }

      let(:inserts) do
        [ insert_1,
          insert_2,
          insert_3
        ]
      end

      before do
        inserts.each do |record|
          insert_statement = <<-CQL
          INSERT INTO #{keyspace}.test_records (id, name)
          VALUES (#{record[0]}, '#{record[1]}');
          CQL
          db.execute(insert_statement)
        end
      end

      it "returns an array of hydrated results" do
        nacho_results = TestRecord.where(name: 'nachos')
        expect(nacho_results.count).to eq(2)

        expect(nacho_results[0].id).to eq(8080)
        expect(nacho_results[0].name).to eq('nachos')

        expect(nacho_results[1].id).to eq(7070)
        expect(nacho_results[1].name).to eq('nachos')
      end
    end

    context "without results" do
      it "returns an empty array" do
        results = TestRecord.where(name: 'pizza')
        expect(results).to eq([])
      end
    end
  end

  describe "configuring the database adapter" do
    let(:some_adapter) { double(:some_adapter) }

    before do
      allow(some_adapter).to receive(:execute) { [] }

      CassandraRecord::Base.configure do |configuration|
        configuration.database_adapter = some_adapter
      end
    end

    context ".create" do
      before do
        allow(some_adapter).to receive(:prepare)
      end

      it "uses the configured database adapter" do
        TestRecord.create(name: 'things')
        expect(some_adapter).to have_received(:prepare)
        expect(some_adapter).to have_received(:execute)
      end
    end

    context ".where" do
      it "uses the configured database adapter" do
        TestRecord.where(name: 'things')
        expect(some_adapter).to have_received(:execute)
      end
    end
  end
end
