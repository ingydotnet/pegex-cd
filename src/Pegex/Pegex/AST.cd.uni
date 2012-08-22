require '../../Pegex/Grammar/Atoms'

merge = (object, rest...) ->
  for hash in rest
    for k, v of hash
      object[k] = v
  object

global.Pegex.Pegex.AST = exports.AST = class AST
  constructor: ->
    @toprule
    @extra_rules = {}
    @prefixes =
      '!': ['+asr', -1]
      '=': ['+asr', 1]
      '.': '-skip'
      '-': '-pass'
      '+': '-wrap'

  got_grammar: (rules) ->
    [meta_section, rule_section] = rules
    grammar = merge {'+toprule': @toprule}, @extra_rules, meta_section
    for rule in rule_section
      for k, v of rule
        grammar[k] = v
    grammar

  got_meta_section: (directives) ->
    meta = {}
    for next in directives
      [key, val] = next
      key = "+#{key}"
      old = meta[key]
      if old?
        if typeof old == 'object'
          old.push val
        else
          meta[key] = [ old, val ]
      else
        meta[key] = val
    meta

  got_rule_definition: (match) ->
    name = match[0]
    @toprule = name if name == 'TOP'
    @toprule ||= name
    value = match[1]

    ret = {}
    ret[name] = value
    ret

  got_bracketed_group: (match) ->
    group = match[1]
    if prefix = match[0]
      group[@prefixes[prefix]] = 1
    if suffix = match[2]
      @set_quantity group, suffix
    group

  got_all_group: (match) ->
    list = @get_group match
    throw 42 unless list.length
    if list.length == 1
      return list[0]
    else
      { '.all': list }

  got_any_group: (match) ->
    list = @get_group match
    throw 42 unless list.length
    return list[0] if list.length == 1
    return { '.any': list }

  get_group: (group) ->
    get = (it) ->
      return unless typeof it == 'object'
      if it instanceof Array
        a = []
        for x in it
          a.push (get x)...
        return a
      else
        return [it]
    return [ (get group)... ]

  got_rule_part: (part) ->
    [rule, sep_on, sep_rule] = part
    if sep_rule
      sep_rule['+eok'] = yes if sep_on == '%%'
      rule['.sep'] = sep_rule
    return rule

  got_rule_reference: (match) ->
    [prefix, ref1, ref2, suffix] = match
    ref = ref1 ? ref2
    node = { '.ref': ref }
    if regex = Pegex.Grammar.Atoms::atoms()[ref]
      @extra_rules[ref] = {'.rgx': regex}
    if suffix
      @set_quantity node, suffix
    if prefix
      [key, val] = [@prefixes[prefix], 1]
      [key, val] = key if typeof key == 'object'
      node[key] = val
    return node

  got_regular_expression: (match) ->
    match = match.replace /\s*#.*\n/g, ''
    match = match.replace /\s+/g, ''
    match = match.replace /\((\:|\=|\!)/g, '(?$1'
    {'.rgx': match}

  got_whitespace_token: (match) ->
    regex = '<ws' + match.length + '>'
    {'.rgx': regex}

  got_error_message: (match) ->
    {'.err': match}

  set_quantity: (object, quantifier) ->
    if quantifier == '*'
      object['+min'] = 0
    else if quantifier == '+'
      object['+min'] = 1
    else if quantifier == '?'
      object['+max'] = 1
    else if quantifier.match /^(\d+)\+$/
      object['+min'] = RegExp.$1
    else if quantifier.match /^(\d+)\-(\d+)$/
      object['+min'] = RegExp.$1
      object['+max'] = RegExp.$2
    else if quantifier.match /^(\d+)$/
      object['+min'] = RegExp.$1
      object['+max'] = RegExp.$1
    else
      throw "Invalid quantifier: '#{quantifier}'"
