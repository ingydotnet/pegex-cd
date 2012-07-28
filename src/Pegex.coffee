exports.VERSION = '0.19'

Grammar = require './Pegex/Grammar'
Receiver = require './Pegex/Receiver'

pegex = (grammar, options) ->
  options ||= {}
  wrap = options.wrap ? true
  receiver = options.receiver ? new Receiver(wrap)
  new Grammar(grammar, receiver)

exports.pegex = pegex

# vim:sw=2 sts=2:
