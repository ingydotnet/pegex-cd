Grammar = require '../Pegex/Grammar'
Parser = require '../Pegex/Parser'

class Module
  parse: (input) ->
    parser = new @parser @grammar @receiver
    parser.parse input

  grammar: ->
    class_name = "#{@.name}.Grammar"
    eval "class #{class_name} extends Grammar"

  parser: ->
    "TODO"

  receiver: ->
    "TODO"
