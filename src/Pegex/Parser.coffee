Input = require '../Pegex/Input'
Receiver = require '../Pegex/Receiver'

class Parser

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

# vim:sw=2 sts=2:
