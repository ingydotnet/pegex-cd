{Compiler} = require '../lib/Pegex/Compiler'
fs = require 'fs'

compile = (grammar_file_path) ->
  compiler = new Compiler
  grammar = String fs.readFileSync grammar_file_path
  tree = compiler.parse(grammar).combinate().tree
  say tree

data = -> [
  label: 'Pegex Grammar'
  grammar: '../pegex-pgx/pegex.pgx'
,
  label: 'TestML Grammar'
  grammar: '../testml-pgx/testml.pgx'
,
#   label: 'YAML Grammar'
#   grammar: '../yaml-pgx/yaml.pgx'
# ,
  label: 'JSON Grammar'
  grammar: '../json-pgx/json.pgx'
]

for t in data()
  test t.label, ->
    compile(t.grammar)
    ok true
