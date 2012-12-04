require './test/lib/test_pegex'

testml_run do |t|
  t.require_or_skip 'psych'

  files = [
    'test/tree.tml',
    'test/tree-pegex.tml',
  ]

  files.each do |f|
    t.data f
    t.eval '*grammar', t.method('run_tree_tests')
  end
end

class TestPegex
  require 'pegex/tree'
  require 'pegex/tree/wrap'
  require 'testast'
  def run_tree_tests block, expr=nil
    label '$BlockLabel - Pegex::Tree'
    run_test(
      block,
      "parse_to_tree('Pegex::Tree', *grammar, *input).yaml.clean == *tree",
    )

    label('$BlockLabel - Pegex::Tree::Wrap');
    run_test(
      block,
      "parse_to_tree('Pegex::Tree::Wrap', *grammar, *input).yaml.clean == *wrap",
    )

    label('$BlockLabel - t::TestAST');
    run_test(
      block,
      "parse_to_tree('TestAST', *grammar, *input).yaml.clean == *ast",
    )
  end

  require 'pegex'
  def parse_to_tree(receiver, grammar, input)
    require receiver.downcase.gsub /::/, '/'
    parser = pegex(grammar, Kernel.eval(receiver))
    return parser.parse(input)
  end
end
