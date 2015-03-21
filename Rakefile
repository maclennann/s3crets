require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

task default: [:rubocop, :spec]

# Ensure default rake tasks load
require 's3crets/default_tasks'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop)
