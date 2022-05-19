# frozen_string_literal: true

require 'simplecov'
require 'set'
reference_branch = 'stable'
begin
  raw_changed_files = `git diff --name-only #{reference_branch}`.strip
rescue SystemCallError
  raw_changed_files = ''
end
changed_files = Set.new(raw_changed_files.split("\n").map { |path| File.expand_path(path.strip) })

SimpleCov.start do
  enable_coverage :branch
  # Global coverage
  minimum_coverage line: 100, branch: 100
  # Enforced for each individual file as well
  minimum_coverage_by_file line: 100, branch: 100

  # Tests don't need test coverage
  add_filter 'spec'
  # Filter paths out. Example: we don't want vendor/bundle results because it's not our code.
  add_filter 'vendor'

  if changed_files.any?
    add_group "Changes from #{reference_branch}" do |src|
      changed_files.include?(src.filename)
    end
  end
end

require 'groupie'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  # config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
