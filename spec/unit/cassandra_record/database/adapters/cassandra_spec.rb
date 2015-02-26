require 'spec_helper'

describe CassandraRecord::Database::Adapters::Cassandra do
  subject(:adapter) { CassandraRecord::Database::Adapters::Cassandra.instance }

  before do
    adapter.use(RSpec.configuration.keyspace)
  end

  after do
    # reset the singleton's @session
    adapter.use(RSpec.configuration.keyspace)
  end

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

  describe "connection retries" do
    let(:cluster_connection) { double(:cluster_connection) }
    let(:session) { double(:session) }
    let(:retry_count) { CassandraRecord::Database::Adapters::Cassandra::MAX_RETRIES }

    before do
      allow(Cassandra).to receive(:cluster) { cluster_connection }
      allow(cluster_connection).to receive(:connect) { session }
    end

    context "#prepare" do
      before do
        allow(session).to receive(:prepare).and_raise Cassandra::Errors::ClientError
      end

      it "retries the expected number of times" do
        expect(session).to receive(:prepare).exactly(retry_count).times
        expect {
          adapter.prepare('some bogus commit statement')
        }.to raise_error(Cassandra::Errors::ClientError)
      end
    end

    context "#execute" do
      before do
        allow(session).to receive(:execute).and_raise Cassandra::Errors::ClientError
      end

      it "retries the expected number of times" do
        expect(session).to receive(:execute).exactly(retry_count).times
        expect {
          adapter.execute('some bogus commit statement')
        }.to raise_error(Cassandra::Errors::ClientError)
      end
    end
  end

end
