class Pegex;end

class Pegex::Input
  require 'xxx'; include XXX # XXX

  attr_accessor :string
  def initialize
    @is_eof = false
    @is_open = false
    @is_close = false
    yield self
  end

  def read
    buffer = @buffer
    @buffer = nil
    @eof = true
    return buffer
  end

  def open
    if defined? @string
      @buffer = @string
    else
      fail "Pegex::Input::open failed. No source to open"
    end
    @is_open = true
  end

  def close
    fail "Attempted to close an unopen Pegex::Input object" \
      if @is_close
    @is_open = false
    @is_close = true
    @buffer = nil
    return self
  end

  def open?
    @is_open
  end
end
