require "gem_publisher"

desc "Publish gem to RubyGems.org"
task :publish_gem do |t|
  gem = GemPublisher.publish_if_updated("govuk_message_queue_consumer.gemspec", :rubygems)
  puts "Published #{gem}" if gem
end
