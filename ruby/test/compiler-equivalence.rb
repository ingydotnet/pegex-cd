$LOAD_PATH.unshift File.join File.dirname(__FILE__), 'lib'

require 'fake_testml'
require 'test_pegex'

class TestML < FakeTestML
  include TestPegex

  def test
    require_or_skip 'psych'

    # *grammar1.compile.yaml == *grammar2.compile.yaml;
    loop ['assert_equal',
        ['yaml', ['compile', '*grammar1']],
        ['yaml', ['compile', '*grammar2']],
    ];
  end
end

$testml = <<'...'
=== Simple Test Case
--- grammar1
a: /x/
--- grammar2
a:
    /x/

=== And over Or Precedence
--- grammar1
a: b c | d
--- grammar2
a: ( b c ) | d

=== And/Or Precedence with joining
--- grammar1
a: b % c | d %% e
--- grammar2
a: ( b % c ) | ( d %% e )

=== And/Or Precedence with grouping
--- grammar1
a:
     b c
   | (
        d
      | e
      | f g h i
   )
--- grammar2
a: ( b c ) | ( d | e | ( f g h i ) )

=== In-Line Comments
--- grammar1
a:  # test
    b c  # not d
    /q/  # skipping to q
    % e  # using e here...
    ;    # comment -> semicolon test
--- grammar2
a: b c /q/ % e

=== Token Per Line
--- SKIP: TODO
--- grammar1
a: /b/
--- grammar2
a
:
/b/

=== Regex Combination
--- SKIP: TODO
--- grammar1: a: /b/ /c/
--- grammar2: a: /bc/

=== Regex Combination by Reference
--- SKIP: TODO
--- grammar1
a: b /c/
b: /b/
--- grammar2: a: /bc/

=== Multiple Rules Names per Definition
--- SKIP: TODO
--- grammar1
a b: /O HAI/
--- grammar2
a: /O HAI/
b: /O HAI/
...
