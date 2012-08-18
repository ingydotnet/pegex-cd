# This is a calulator parser, that handles the following:
# * Calculations involving:
#   * Positive integers
#   * `+ - * / ^` operators
#   * Precedence and associativity
#   * Parenthetical grouping
# * Whitespace separation (or not)
# * The receiver class evaluates the expression and returns the result.
#
# Originally inspired by:
#   https://github.com/dmajda/pegjs/blob/master/examples/arithmetics.pegjs

{pegex} = require '../lib/Pegex'

grammar = """
expr:   item+ % op
op:     /~([<PLUS><DASH><STAR><SLASH><CARET>])~/
item:   num | group
num:    /(<DIGIT>+)/
group:  /~<LPAREN>~/
        expr
        /~<RPAREN>~/
"""

class Calculator
  operators =
    '+': f: 'add', p: 1, a: 'left'
    '-': f: 'sub', p: 1, a: 'left'
    '*': f: 'mul', p: 2, a: 'left'
    '/': f: 'div', p: 2, a: 'left'
    '^': f: 'exp', p: 3, a: 'right'

  got_num: (num) -> Number num

  got_group: ([expr]) -> expr

  # http://en.wikipedia.org/wiki/Shunting-yard_algorithm
  got_expr: (expr) ->
    [out, ops] = [[],[]]
    out.push expr.shift()
    while expr.length
      op = expr.shift()
      {p, a} = operators[op]
      while ops.length
        p2 = operators[ops[0]].p
        break if p > p2 or p == p2 and a == 'right'
        out.push ops.shift()
      ops.unshift op
      out.push expr.shift()
    out.concat ops

  final: (expr) ->
    @evaluate expr

  evaluate: (expr) ->
    return expr[0] if expr.length == 1
    func = 'do_' + operators[expr.pop()].f
    val2 = @get_value expr
    @[func] @get_value(expr), val2

  get_value: (expr) ->
    if expr[expr.length - 1] instanceof Array
      @evaluate expr.pop()
    else if operators[expr[expr.length - 1]]
      @evaluate expr
    else
      expr.pop()

  do_add: (a, b) -> a + b
  do_sub: (a, b) -> a - b
  do_mul: (a, b) -> a * b
  do_div: (a, b) -> a / b
  do_exp: (a, b) -> Math.pow(a, b)

test = (input) -> console.log(
  "#{input} =",
  pegex(grammar, {receiver: (new Calculator)}).parse input
)

test '2'
test '2 + (4 + 6) * 8'
test '2 * 4'
test '2 * 4 + 6'
test '2 + 4 * 6 + 1'
test '2 ^ 3 ^ 2'
test '2 ^ (3 ^ 2)'
test '2 * 2^3^2'
test '(2^5)^2'
test '2^5^2'
test '0*1/(2+3)-4^5'
test '2/0+1'
