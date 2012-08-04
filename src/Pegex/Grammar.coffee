exports.Grammar = class Grammar
  constructor: (a = {}) ->
    {@text} = a; @text ?= ''
    {@tree} = a
    {@parser} = a
    {@receiver} = a
    {@receiver} = a

  make_tree: ->
    throw "Can't create a grammar. No 'text' or 'tree'." unless @text
    Compiler = require '../Pegex/Compiler'
    Compiler::compile(text).tree

  parse: (input, start_rule...) ->
    {parser} = @
    if parser?
      Parser = require '../Pegex/Parser'
      {receiver} = @
      if typeof receiver != 'object'
        Receiver = require receiver
        receiver = new Receiver()
      parser = new Parser(
        'grammar': @
        'receiver': receiver
      )
      parser.parse input, start_rule
