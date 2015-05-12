require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'
require 'active_support/inflector'

module CassandraRecord
  class Base
    class << self
      def create(attributes)
        new(attributes).create
      end

      def batch_create(array_of_attributes, options={})
        batch = configuration.database_adapter.session.batch do |batch|
          array_of_attributes.map do |attr|
            batch.add(new(attr).send(:insert_statement, attr, options), attr.values)
          end
        end

        configuration.database_adapter.session.execute(batch)
        array_of_attributes.map { |attr| new(attr) }
      end

      def where(attributes={})
        new.where(attributes)
      end

      def configure
        yield configuration
      end

      def configuration
        @@configuration ||= Configuration.new
      end
    end

    attr_accessor :attributes

    def initialize(attributes={})
      @attributes = HashWithIndifferentAccess.new(attributes)
    end

    def where(options={})
      db.execute(where_statement(options)).map do |attributes|
        self.class.new(attributes)
      end
    end

    def create(options={})
      db.execute(insert_statement(attributes, options), *attributes.values)
      self
    end

    private

    def db
      self.class.configuration.database_adapter
    end

    def where_statement(options={})
      Statement.where(table_name, options)
    end

    def insert_statement(attributes, options={})
      @insert_statement ||= db.prepare(insert_cql(attributes, options))
    end

    def insert_cql(attributes, options={})
      Statement.create(table_name, attributes.keys, attributes.values, options)
    end

    def table_name
      ActiveSupport::Inflector.tableize(self.class.name).gsub(/\//, '_')
    end

    def method_missing(method, *args, &block)
      if attributes.has_key?(method)
        attributes[method]
      else
        super(method, *args, &block)
      end
    end

    class Configuration
      attr_accessor :database_adapter

      def initialize(adapter=Database::Adapters::Cassandra.instance)
        adapter
      end
    end

  end
end
