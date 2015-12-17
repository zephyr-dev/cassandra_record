require "bundler/gem_tasks"
require 'cassandra_record'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task :default => :spec
rescue LoadError
  # no rspec available
  # end
  puts "Unable to load RSpec tasks"
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
