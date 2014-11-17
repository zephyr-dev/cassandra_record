require 'spec_helper'

describe CassandraRecord::Database::Adapters::Cassandra do
  subject(:adapter) { CassandraRecord::Database::Adapters::Cassandra.instance }

  describe "#configuration" do
    before do
      adapter.configuration do |config|
        config[:thing] = 'stuff'
        config[:other_thing] = 'other_stuff'
      end
    end

    specify { expect(adapter.configuration[:thing]).to eq('stuff') }
    specify { expect(adapter.configuration[:other_thing]).to eq('other_stuff') }
  end

end
