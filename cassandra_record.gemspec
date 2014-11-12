# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cassandra_record/version'

Gem::Specification.new do |spec|
  spec.name          = "cassandra_record"
  spec.version       = CassandraRecord::VERSION
  spec.authors       = ["Gust"]
  spec.email         = ["zephyr-dev@googlegroups.com"]
  spec.summary       = %q{A familiar interface to Cassandra-backed models}
  spec.description   = %q{A familiar interface to Cassandra-backed models}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "activesupport"
  spec.add_runtime_dependency "cassandra-driver"
end
