require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)

# Load local tasks
Dir['tasks/**/*.rake'].each { |file| load file }

task(:default).clear
task :default => %i[rubocop spec]
