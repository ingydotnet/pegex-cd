require 'rake/testtask'

task default: :test

desc "Run all test cases"
Rake::TestTask.new do |t|
  t.verbose = true
  #t.test_files = FileList['test/*.rb']
  t.test_files = [
    'test/compiler-checks.rb',
    'test/compiler-equivalence.rb',
    'test/compiler.rb',
    'test/export_ok.rb',
    'test/grammar-api.rb',
#     'test/tree.rb',
    'test/error.rb',
  ]
end
