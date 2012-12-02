$LOAD_PATH.unshift File.join File.dirname(__FILE__), 'lib'

require 'fake_testml'
require 'test_pegex'

class TestML < FakeTestML
  require 'xxx'; include XXX
  include TestPegex

  def test
    require_or_skip 'psych'

    data 'test/compiler.tml'

    loop ['*grammar'], method('run_tests')
  end

  def run_tests block, expr=nil
    label '$BlockLabel - Compiler output matches bootstrap?'
    run_test(
      block,
      [ 'assert_equal',
        ['yaml', ['compile', '*grammar']],
        ['yaml', ['compile', '*grammar']],
      ],
    )

    label '$BlockLabel - Compressed grammar compiles the same?'
    run_test(
      block,
      [ 'assert_equal',
        ['yaml', ['compile', ['compress', '*grammar']]],
        ['yaml', ['compile', ['compress', '*grammar']]],
      ],
    )

    label '$BlockLabel - Compressed grammar matches uncompressed?'
    run_test(
      block,
      [ 'assert_equal',
        ['yaml', ['compile', ['compress', '*grammar']]],
        ['yaml', ['compile', '*grammar']],
      ],
    )
  end

  def compress grammar_text
    grammar_text.gsub! /([^;])\n(\w+\s*:)/ do |m|
      "#{$1};#{$2}"
    end
    grammar_text.gsub! /\s/, ''

    # XXX mod/quant ERROR rules are too prtective here:
    grammar_text.gsub! />%</, '> % <'
    return "#{grammar_text}\n"
  end
end
