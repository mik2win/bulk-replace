# frozen_string_literal: true

require_relative 'lib/bulk_replace/version'

Gem::Specification.new do |spec|
  spec.name        = 'bulk_replace'
  spec.version     = BulkReplace::VERSION
  spec.summary     = 'Bulk-replace text strings across files in a directory'
  spec.authors     = ['mik2win']
  spec.homepage    = 'https://github.com/mik2win/bulk-replace'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 3.2.0'

  spec.files       = Dir['lib/**/*', 'exe/*', 'README.md', 'LICENSE']
  spec.bindir      = 'exe'
  spec.executables = ['bulk-replace']

  spec.add_development_dependency 'rspec', '~> 3.13'
end
