exports.VERSION = '0.19'

Grammar = require './Pegex/Grammar'
Receiver = require './Pegex/Receiver'

class Pegex
  pegex: (grammar, options) ->
    options ||= {}
    wrap = options.wrap ? true
    receiver = options.receiver ? new Receiver(wrap)
    new Grammar(grammar, receiver)

exports.pegex = Pegex.prototype.pegex
