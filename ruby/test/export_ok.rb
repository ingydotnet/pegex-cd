require './test/lib/test_pegex'

testml_run do |t|
  require 'pegex'
  t.assert method('pegex'),
    'pegex is exported'

  parser1 = pegex "foo: <bar>\n"

  t.assert parser1.kind_of?(Pegex::Parser),
    'pegex returns a Pegex::Parser object'

  t.assert_equal parser1.grammar.tree['+toprule'], 'foo',
    'pegex() contains a grammar with a compiled tree'

  parser2 = pegex(<<'...');
number: /<DIGIT>+/
...

  begin
    parser2.parse '123'
    t.assert true, 'parser2.parse worked'
  rescue
    t.assert false, "parser2.parse failed: #{$!.message}"
  end

  t.assert parser2.kind_of?(Pegex::Parser),
    'grammar property is Pegex::Parser object'

  tree2 = parser2.grammar.tree
  t.assert tree2, 'Grammar object has tree';
  t.assert tree2.kind_of?(Hash), 'Grammar object is compiled to a tree'

  t.assert_equal tree2['+toprule'], 'number',
    '_FIRST_RULE is set correctly'
end
