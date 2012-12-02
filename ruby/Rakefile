require 'rake/testtask'

task default: :test

desc "Run all test cases"
FileList['test/*.rb'].each do |file|
  Rake::TestTask.new do |test|
    test.verbose = true
    test.test_files = [file]
  end
end
