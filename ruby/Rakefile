require 'rake/testtask'

task default: :test

Rake::TestTask.new do |t|
  t.verbose = true
  t.test_files = FileList['test/*.rb']
end

test_files = [
  'test/compiler-checks.rb',
  'test/compiler-equivalence.rb',
  'test/compiler.rb',
  'test/export_ok.rb',
  'test/grammar-api.rb',
  'test/tree.rb',
  'test/error.rb',
]

# desc "Run all test cases"
# test_files.each do |f|
#   Rake::TestTask.new do |t|
#     t.verbose = true
#     t.test_files = FileList[f]
#   end
# end

# Rake::TestTask.new do |t|
#   t.verbose = true
#   t.test_files = test_files
# end
