require '../Pegex'

global.Pegex.Input = exports.Input = class Input
  constructor: (a = {}) ->
    {@string} = a
    {@file} = a
    {@handle} = a
    @_buffer = ''
    @_is_eof = false
    @_is_open = false
    @_is_close = false

  read: ->
    throw "Attempted Pegex.Input.read before open" unless @_is_open
    throw "Attempted Pegex.Input.read after EOF" if @_is_eof
    buffer = @_buffer
    @_buffer = null
    @_is_eof = yes
    buffer

  open: ->
    throw "Attempted to reopen Pegex.Input object" if @_is_open or @_is_close
    if @string?
      @_buffer = @string
    else
      throw "Pegex.Input.open failed. No source to open."
    @_is_open = yes
    @

  close: ->
    throw "Attempted to close an unopen Pegex.Input object" if @_is_close
    @_is_open = no
    @_is_close = yes
    @_buffer = null
    @

