class Input

constructor: () ->
  @string = null
  @file = null
  @handle = null
  @_buffer = ''
  @_is_eof = false
  @_is_open = false
  @_is_close = false

# vim:sw=2 sts=2:
