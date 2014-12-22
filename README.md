# Cassandra Record

## Installation

Add this line to your application's Gemfile:

```bash
gem 'cassandra_record'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install cassandra_record
```

## Usage

CassandraRecord models are based on the following Cassandra table:

```sql
CREATE TABLE thingies (
  id int,
  name text,
  PRIMARY KEY (id)
);
```

__A simple Cassandra-backed model__

Define the model by inheriting from CassandraRecord::Base. ...and you're done. ...you're welcome

```ruby
class Thingy < CassandraRecord::Base
end

# record creation
Thingy.create(id: 123, name: 'pizza')

# record retrieval and attribute access
my_thingy = Thingy.where(id: 123)
my_thingy.name   # => pizza
```

__A model with creation options__

Override the instance-level #create method.
Overriding the instance-level #create method will apply the configured options to all created records. 

```ruby
class Thingy < CassandraRecord::Base
  TTL = 3600 # one hour

  def create
    options = { ttl: TTL }
    super(options)
  end
end

# record creation
# this record will auto-expire in 1 hour.
Thingy.create(id: 123, name: 'spaghetti')    
```

## Contributing

1. Fork it ( https://github.com/zephyr-dev/cassandra_record/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


