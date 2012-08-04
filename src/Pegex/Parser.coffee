{Input} = require '../Pegex/Input'
{Receiver} = require '../Pegex/Receiver'

exports.Parser = class Parser

  constructor: (@grammar, @receiver) ->
    @receiver ||= new require './Pegex/Receiver'
    @throw_on_error = on
    @wrap = @receiver.wrap
    @input = ''
    @buffer = ''
    @error = null
    @position = 0
    @debug = off

  parse: (input, start_rule) ->
    @input = input
    @buffer = @input.read()
    grammar = @grammar ?
      throw "No 'grammar'. Can't parse"
    if typeof grammar == 'string'
      require '../' + grammar
      @grammar = new grammar
    start_rule ?= @grammar.tree['+toprule'] ? do ->
      if @grammar.tree['TOP']
        'TOP'
      else
        throw "No starting rule for Pegex.Parser.parse"
    receiver = @receiver ?
      throw "No 'receiver'. Can't parse"
    if typeof receiver == 'string'
      require '../' + receiver
      @receiver = new receiver
    @receiver.parser = @

    match = @match start_rule
    return unless match

    @input.close()

    return @receiver.data || match

  match: (rule) ->
    @receiver.initialize rule if @receiver::initialize
    match = @match_next { '.ref': rule }
    if ! match or @position < @buffer.length
      @throw_error "Parse document failed for some reason"
      return
    match = match[0]
    match = @receiver.finalize match rule if @receiver::finalize
    match = {rule: []} unless match
    if rule == 'TOP'
      match = match['TOP'] ? match
    match

  get_min_max: (next) ->
    return @match_next_with_sep next if next['.sep']
    [min, max] = [ next['+min'], next['+max'] ]
    if min?
      if max?
        [min, max]
      else
        [min, 0]
    else
      if max?
        [0, max]
      else
        [1, 1]

  match_next: (next) ->
    return @match_next_with_sep next if next['.sep']

    [min, max] = @get_min_max next
    assertion = next['+asr'] ? 0
    keys = ['ref', 'rgx', 'all', 'err', 'code']
    [rule, kind] = for key in keys when next[".#{key}"]?
      [next[".#{key}"], key]

    [match, position, count, method] =
      [[], @position, 0, "match_#{kind}"]

    while return_ = method.call this rule next
      position = @position unless assertion
      count++
      match.push return_...
      break if max == 1

    if max != 1
      match = [ match ]
      @set_position position

    result = (count >= min and (not max or count <= max))
    result ^= (assertion == -1)

    @set_position position if not result or assertion

    match = [] if next['-skip']

    result && match || 0

  match_next_with_sep: (next) ->
    [min, max] = @get_min_max next
    [rule, kind] = for key in keys when next[".#{key}"]?
      [next[".#{key}"], key]
    separator = next['.sep']

    [match, position, count, method, scount, smin, smax] =
      [[], @position, 0, "match_#{kind}", 0,
        @get_min_max separator]

    while return_ = method.call this rule next
      position = @position
      count++
      match.push return_...
      break unless return_ = @match_next separator
      return2 = [ return_... ]
      if return2.length
        return2 = ['XXX'] ix smax != 1
        match.push return2...
      scount++
    if max != 1
      match = [ match ]

    result = (count >= min and (not max or count <= max))
    @set_position position if count == scount and
      not separator['+eok']

    match = [] if next['-skip']
    return result && match || 0

  match_ref: (ref, parent) ->
    rule = @grammar.tree[ref]
    rule ||= if @::["match_rule_#{ref}"] then { '.code': ref } else
        throw "\n\n*** No grammar support for '#{ref}'\n\n"
    trace = not rule['+asr'] and @debug
    @trace "try_#{ref}" if trace

    match = if typeof rule == 'function' then rule.call @ else @match_next rule

    if match
      @trace "got_#{ref}" if trace
      if not rule['+asr'] and not parent['-skip']
        callback = "got_#{ref}"
        sub = @receiver::[callback]
        if sub?
          match = [ sub.call @receiver, match[0] ]
        else if @wrap and not parent['-pass'] or parent['-wrap']
          match = if match.length then [ {ref: match[0]} ] else []
    else
      @trace "not_#{ref}"
      match = 0

    match

  xxx_terminator_hack: 0
  xxx_terminator_max: 1000
  match_rgx: (regexp, parent) ->
    start = @position
    if start >= @buffer.length and
      @xxx_terminator_hack++ > @xxx_terminator_max
        throw "Your grammar seems to not terminate at end or stream"
    re = new RegExp regexp, 'g'
    re.lastIndex = start
    m = re.exec @buffer
    return 0 if not m
    finish = re.lastIndex
    match = m[num] for num in [1...m.length]
    match = [ match ] if m.length > 1
    @set_position finish
    return match

  match_all: (list, parent) ->
    pos = @position
    set = []
    len = 0
    for elem in list
      if match = @match_next elem
        continue if elem['+asr'] or elem['-skip']
        set.push match
        len++
      else
        @set_position pos
        return 0
    set = [ set ] if len > 1
    return set

  match_any: (list, parent) ->
    for elem in list
      if match = @match_next elem
        return match
    return 0

  match_err: (error) ->
    @throw_error error

  match_code: (code) ->
    method = "match_rule_#{code}"
    method.call @

  set_position: (position) ->
    @position = position
    @farthest = position if position > @farthest

  trace: (action) ->
    indent = action.match /^try_/
    @indent ||= 0
    @indent-- unless indent
    indentation = ''
    indentation += ' ' for x in [1..@indent]
    @indent++ if indent
    snippet = @buffer.substr @position
    snippet = snippet.substr 0, 30 if snippet.length > 30
    snippet = snippet.replace /\n/, '\\n'
    console.warn "#{indentation}>#{snippet}<\n"

  throw_error: (msg) ->
    @format_error msg
    return 0 unless @throw_on_error
    throw @error

  format_error: (msg) ->
    position = @farthest
    line = @buffer.substr 0, (position match /\n/g)? length + 1
    column = position - @buffer.lastIndexOf "\n", position
    context = @buffer.substr position, 50
    context = context.replace /\n/, '\\n'
    @error = """
Error parsing Pegex document:
  msg: #{msg}
  line: #{line}
  column: #{column}
  context: #{context}
  position: #{position}
"""
