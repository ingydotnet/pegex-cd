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
  label: 'Single Rule'
  grammar: """
    a: <x>
  """
  yaml: """
    a:
      .ref: x
  """
,
  label: 'Single Rule with no brackets'
  grammar: """
    a: x
  """
  yaml: """
    a:
      .ref: x
  """
,
  label: 'Single Rule With Trailing Quantifier'
  grammar: """
    a: <x>*
  """
  yaml: """
    a:
      +min: 0
      .ref: x
  """
,
  label: 'Single Rule With Trailing Quantifier (no angles)'
  grammar: """
    a: x*
  """
  yaml: """
    a:
      +min: 0
      .ref: x
  """
,
  label: 'Single Rule With Leading Assertion'
  grammar: """
    a: =<x>
  """
  yaml: """
    a:
      +asr: 1
      .ref: x
  """
,
  label: 'Single Regex'
  grammar: """
    a: /x/
  """
  yaml: """
    a:
      .rgx: x
  """
,
  label: 'Single Error'
  grammar: """
    a: `x`
  """
  yaml: """
    a:
      .err: x
  """
,
  label: 'Unbracketed All Group'
  grammar: """
    a: <x> <y>
  """
  yaml: """
    a:
      .all:
      - .ref: x
      - .ref: y
  """
,
  label: 'Unbracketed Any Group'
  grammar: """
    a: /x/ | <y> | `z`
  """
  yaml: """
    a:
      .any:
      - .rgx: x
      - .ref: y
      - .err: z
  """
,
  label: 'Bracketed All Group'
  grammar: """
    a: ( <x> <y> )
  """
  yaml: """
    a:
      .all:
      - .ref: x
      - .ref: y
  """
,
  label: 'Bracketed Group With Trailing Modifier'
  grammar: """
    a: ( <x> <y> )?
  """
  yaml: """
    a:
      +max: 1
      .all:
      - .ref: x
      - .ref: y
  """
,
  label: 'Bracketed Group With Leading Modifier'
  grammar: """
    a: .( =<x> <y> )
  """
  yaml: """
    a:
      -skip: 1
      .all:
      - +asr: 1
        .ref: x
      - .ref: y
  """
,
  label: 'Multiple Groups'
  grammar: """
    a: ( <x> <y> ) ( <z> | /.../ )
  """
  yaml: """
    a:
      .all:
      - .all:
        - .ref: x
        - .ref: y
      - .any:
        - .ref: z
        - .rgx: '...'
  """
,
  label: 'Whitespace in Regex'
  grammar: """
    a: /<DOT>* (<DASH>{3})
        <BANG>   <BANG>
       /
  """
  yaml: """
    a:
      .rgx: \\.*(\\-{3})!!
  """
,
  label: 'Directives'
  grammar: """
    %grammar foo
    %version 1.2.3
  """
  yaml: """
    +grammar: foo
    +version: 1.2.3
  """
,
  label: 'Multiple Duplicate Directives'
  grammar: """
    %grammar foo
    %include bar
    %include baz
  """
  yaml: """
    +grammar: foo
    +include:
    - bar
    - baz
  """
]

tests = []
for t in data()
  continue if t.SKIP
  if t.ONLY
    tests = [t]
    break
  tests.push t

for t in tests
  t.grammar += "\n"
  t.yaml += "\n"
  test t.label, ->
    deepEqual compile(t.grammar), YAML.load t.yaml
