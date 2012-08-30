###
name:      Pegex
abstract:  Acmeist PEG Parsing Framework
author:    Ingy döt Net <ingy@ingy.net>
license:   MIT
copyright: 2010-2012
###

global.Pegex = class Pegex
# XXX version needs to come from package.yaml or cdent.yaml
global.Pegex.VERSION = '0.0.3'

exports.pegex = (grammar_text, {receiver, wrap} = {}) ->
  require './Pegex/Parser'
  require './Pegex/Grammar'

  unless grammar_text?
    throw "pegex() requires at least 1 argument, a pegex grammar string"
  new Pegex.Parser new Pegex.Grammar(text: grammar_text), _get_receiver receiver, wrap

_get_receiver = (receiver, wrap) ->
  if receiver?
    if typeof receiver == 'string'
      require receiver
      receiver = new receiver
  else
    require './Pegex/Receiver'
    receiver = new Pegex.Receiver
    if ! wrap?
      receiver.wrap = on
  if wrap?
    receiver.wrap = wrap
  receiver
