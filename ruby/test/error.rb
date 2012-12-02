$:.unshift File.dirname(__FILE__) + '/lib'

require 'fake_testml'
require 'test_pegex'
require 'pegex'

class TestML < FakeTestML
  require 'xxx'; include XXX # XXX

  include TestPegex
  include Pegex::Export

  def test
    loop ['assert_match',
      ['Catch', %w(parse *grammar *input)],
      '*error',
    ]
  end

  def parse grammar, input
    parser = pegex grammar
    return parser.parse input
  end
end

$testml = <<'...'
=== Error fails at furthest match
# XXX This one not testing much.
--- grammar
a: b+ c
b: /b/
c: /c/
--- input
bbbbddddd
--- error: ddddd\n

### TODO ###
# === Pegex: Illegal meta rule
# --- grammar
# %grammar Test
# %foobar Quark
# a: /a+/
# --- input
# aaa
# --- error: Illegal meta rule

=== Pegex: Rule header syntax error
--- grammar
a|: /a+/
--- input
aaa
--- error: Rule header syntax error

=== Pegex: Rule ending syntax error
--- grammar
a: /a+/ |
--- input
aaa
--- error: Rule ending syntax error

=== Pegex: Illegal rule modifier
--- grammar
a: /a+/
b: ^<a>1-2
--- input
aaa
--- error: Illegal rule modifier

=== Pegex: Missing > in rule reference
--- grammar
a: /a+/
b: !<a1-2
--- input
aaa
--- error: Missing > in rule reference

=== Pegex: Missing < in rule reference
--- grammar
a: /a+/
b: !a>1-2
--- input
aaa
--- error: Rule ending syntax error
# --- error: Missing < in rule reference

=== Pegex: Illegal character in rule quantifier
--- grammar
a: /a+/
b: !a^1-2
--- input
aaa
--- error: Rule ending syntax error
# --- error: Illegal character in rule quantifier

=== Pegex: Unprotected rule name with numeric quantifier
--- grammar
a: /a+/
b: !a1-2
--- input
aaa
--- error: Rule ending syntax error
# --- error: Unprotected rule name with numeric quantifier

=== Pegex: Runaway regular expression
--- grammar
a: /a+
--- input
aaa
--- error: Runaway regular expression

=== Pegex: Illegal group rule modifier
--- grammar
a: /a+/
b: !(a =<a>)1-2
--- input
aaa
--- error: Illegal group rule modifier

=== Pegex: Runaway rule group
--- grammar
a: /a+/
b: .(a =<a>1-2
--- input
aaa
--- error: Runaway rule group

=== Pegex: Illegal character in group rule quantifier
--- grammar
a: /a+/
b: .(a =<a>)^2
--- input
aaa
--- error: Rule ending syntax error
# --- error: Illegal character in group rule quantifier

=== Pegex: Multi-line error messages not allowed
--- grammar
a: /a+/
b: `This is legal`
c: `This is
 
illegal`
--- input
aaa
--- error: Multi-line error messages not allowed

=== Pegex: Runaway error message
--- grammar
a: /a+/
b: `This is legal`
c: `This is

illegal
--- input
aaa
--- error: Runaway error message

=== Pegex: Leading separator form (BOK) no longer supported
--- grammar
a: /a+/ %%% ~
--- input
aaa
--- error: Rule ending syntax error
# --- error: Leading separator form (BOK) no longer supported

=== Pegex: Illegal characters in separator indicator
--- grammar
a: /a+/ %%~%%^%% ~
--- input
aaa
--- error: Rule ending syntax error
# --- error: Illegal characters in separator indicator
...
