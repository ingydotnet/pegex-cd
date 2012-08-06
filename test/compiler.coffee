{Compiler} = require '../lib/Pegex/Compiler'
YAML = require 'js-yaml'

compile = (grammar) ->
  compiler = new Compiler
  tree = compiler.parse(grammar).combinate().tree
  delete tree['+toprule']
  tree

data = -> [
  label: 'Simple Grammar'
  grammar: """
    a: ( <b> <c>* )+
    b: /x/
    c: <x>
  """
  yaml: """
    a:
      +min: 1
      .all:
      - .ref: b
      - +min: 0
        .ref: c
    b:
      .rgx: x
    c:
      .ref: x
  """
,
  ONLY: true
  label: 'Single Rule'
  grammar: """
    a: <x>
  """
  yaml: """
    a:
      .ref: x
  """
]

tests = []
for t in data()
  if t.ONLY
    tests = [t]
    break
  tests.push t

for t in tests
  t.grammar += "\n"
  t.yaml += "\n"
  test t.label, ->
    deepEqual compile(t.grammar), YAML.load t.yaml
