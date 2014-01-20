# Rakefile
require 'rake/testtask'

task :default => :test

desc "Run all tests"
  task(:test) do
  Rake::TestTask.new do |t|
    t.pattern = "spec/*_spec.rb"
  end
end