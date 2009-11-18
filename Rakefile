require 'rake'
require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end

Rake::Task[:test].comment = "Run all tests"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "lyris"
    gemspec.summary = "Lyris/EmailLabs API"
    gemspec.description = "A wrapper for the Lyris/EmailLabs API to simplify integration"
    gemspec.email = "brent.faulkner@mosaic.com"
    # gemspec.homepage = "http://mosaic.com"
    gemspec.authors = ["S. Brent Faulkner"]
    gemspec.add_dependency('hpricot', '>= 0.8.1')
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end
