require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

# Load local tasks
Dir['tasks/**/*.rake'].each { |file| load file }

task(:default).clear
task :default => [:spec]
