require './test/lib/test_pegex'
require 'pegex/grammar'

class MyGrammar1 < Pegex::Grammar
  def initialize
    @text = <<'...'
foo: /xyz/ <bar>
bar:
    /abc/ |
    <baz>
baz: /def/
...
  end
end

testml_run do |t|
  g1 = MyGrammar1.new
  g1.make_tree
  t.assert_equal g1.tree['+toprule'], 'foo',
    'MyGrammar1 compiled a tree from its text'
end
