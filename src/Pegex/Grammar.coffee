class Grammar
  constructor: (a = {}) ->
    {@text} = a; @text ?= ''
    {@tree} = a
    {@parser} = a
    {@receiver} = a
    {@receiver} = a

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

# vim:sw=2 sts=2:
