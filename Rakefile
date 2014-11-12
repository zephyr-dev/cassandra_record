require "bundler/gem_tasks"
require 'cassandra_record'

task :environment do
end

namespace :cassandra_record do 
  namespace :structure do
    desc "Loads your structures"
    task :load => :environment do
      filepath = File.dirname(__FILE__) + "/db/cassandra_structure.cql"
      `cqlsh -f #{filepath}`
    end
  end
end
