require './test/lib/test_pegex'

testml_run do |t|
  t.require_or_skip 'psych'

  files = [
    'test/tree.tml',
    'test/tree-pegex.tml',
  ]

  files.each do |f|
    t.data f
    t.loop ['*grammar'], t.method('run_tests')
  end
end

class TestPegex
  require 'pegex/tree'
  require 'pegex/tree/wrap'
  require 'testast'
  def run_tests block, expr=nil
    label '$BlockLabel - Pegex::Tree'
    run_test(
      block,
      ['assert_equal',
        ['clean', ['yaml', ['parse', Pegex::Tree, '*grammar', '*input']]],
        '*tree',
      ],
    )

    label('$BlockLabel - Pegex::Tree::Wrap');
    run_test(
      block,
      ['assert_equal',
        ['clean', ['yaml', ['parse', Pegex::Tree::Wrap, '*grammar', '*input']]],
        '*wrap',
      ],
    )

    label('$BlockLabel - t::TestAST');
    run_test(
      block,
      ['assert_equal',
        ['clean', ['yaml', ['parse', TestAST, '*grammar', '*input']]],
        '*ast',
      ],
    )
  end

  require 'pegex'
  def parse(receiver, grammar, input)
    parser = pegex(grammar, receiver)
    return parser.parse(input)
  end
end
