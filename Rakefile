require 'rake/testtask'
require 'rake/file_utils'

# Thanks https://aws.amazon.com/blogs/developer/running-your-minitest-unit-test-suite/

desc 'Runs the app'
task :run do
  sh 'bundle exec ruby app.rb'
end

task :default => :run

Rake::TestTask.new do |t|
  t.libs.push 'app/test'
  t.pattern = 'app/test/*.rb'
  t.warning = false
  t.verbose = true
end

desc 'Generates a coverage report'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['test'].execute
end

desc 'View coverage report'
task :view do
  sh 'open coverage/index.html'
end