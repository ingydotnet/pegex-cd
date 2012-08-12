require '../Pegex/Grammar'
require '../Pegex/Parser'

exports.Module = class Module
  parse: (input) ->
    parser = new @parser @grammar @receiver
    parser.parse input

  grammar: ->
    class_name = "#{@.name}.Grammar"
    eval "class #{class_name} extends Pegex.Grammar"

  parser: ->
    "TODO"

  receiver: ->
    "TODO"
