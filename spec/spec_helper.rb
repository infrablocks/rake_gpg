# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'bundler/setup'

require 'rake'
require 'support/shared_contexts/rake'
require 'support/shared_contexts/gpg'
require 'support/matchers'

require 'tempfile'

require 'rake_gpg'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
