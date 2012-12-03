require 'rake/testtask'

task default: :test

desc "Run all test cases"
Rake::TestTask.new do |t|
  t.verbose = true
  t.test_files = FileList['test/*.rb']
end
