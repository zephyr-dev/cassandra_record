require 'spec_helper'

describe CassandraRecord::Base do
  let(:db) { RSpec.configuration.db }
  let(:keyspace)  { RSpec.configuration.keyspace }

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
  end

  describe ".where" do
    context "with results" do
      before do
        insert_1 = <<-CQL
          INSERT INTO #{keyspace}.test_records (id, name)
          VALUES (9090, 'burgers');
        CQL
        insert_2 = <<-CQL
          INSERT INTO #{keyspace}.test_records (id, name)
          VALUES (8080, 'nachos');
        CQL
        insert_3 = <<-CQL
          INSERT INTO #{keyspace}.test_records (id, name)
          VALUES (7070, 'nachos');
        CQL

        db.execute(insert_1)
        db.execute(insert_2)
        db.execute(insert_3)
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

end
