require 'test/unit'

class FakeTestML < Test::Unit::TestCase
  require 'xxx'; include XXX # XXX

  def require_or_skip module_
    require module_
    rescue exit
  end

  def data input
    unless input.match /\n/
      File.open(input, 'r') {|f| input = f.read}
    end
    @testml = parse_tml input
  end

  def assert_testml
    return if defined? @testml
    raise "No testml data provided" unless $testml
    data $testml
  end

  def label text
    @label = text
  end

  def loop expr, callback=nil
    assert_testml
    callback ||= method 'run_test'
    get_blocks(expr).each do |block|
      @error = nil
      callback.call(block, expr)
      raise @error if @error
    end
  end

  def run_test block, expr
    # puts block[:title]
    block = get_blocks(expr, [block]).first or return
    evaluate expr, block
  end

  def assert_equals got, want, block
    if got != want
      on_fail if respond_to? 'on_fail'
      File.open('/tmp/got', 'w') {|f| f.write got}
      File.open('/tmp/want', 'w') {|f| f.write want}
      puts `diff -u /tmp/want /tmp/got`
    end
    assert_equal want, got, block[:title]
  end

  def catch
    fail # TODO
  end

  def evaluate expr, block
    expr = ['', expr] if expr.kind_of? String
    func = expr.first
    args = expr[1..expr.length-1].collect do |ex|
      if ex.kind_of? Array
        evaluate ex, block
      elsif ex =~ /\A\*(\w+)\z/
        block[:points][$1]
      else
        ex
      end
    end
    return if @error and func != 'catch'
    return args.first if func.empty?
    args << block if func =~ /^assert_/
    return method(func).call(*args)
    begin
      return method(func).call(*args)
    rescue
      @error = $!.message
    end
  end

  def get_blocks expr, blocks=@testml
    want = expr.flatten.grep(/^\*/).collect{|ex| ex.gsub /^\*/, ''}
    only = blocks.select{|block| block['ONLY']}
    blocks = only unless only.empty?
    final = []
    blocks.each do |block|
      next if block['SKIP']
      ok = true
      want.each do |w|
        unless block[:points][w]
          ok = false
          break
        end
      end
      if ok
        final << block
        break if block['LAST']
      end
    end
    return final
  end

  def parse_tml string
    string.gsub! /^#.*\n/, ''
    string.gsub! /^\\/, ''
    string.gsub! /^\s*\n/, ''
    blocks = string.split /(^===.*?(?=^===|\z))/m
    blocks.reject!{|b| b.empty?}
    blocks.each do |block|
      block.gsub! /\n+\z/, "\n"
    end

    array = []
    blocks.each do |string_block|
      block = {}
      string_block.gsub! /^===\ +(.*?)\ *\n/, '' \
        or fail "No block title! #{string_block}"
      block[:title] = $1
      while !string_block.empty? do
        if string_block.gsub! /\A---\ +(\w+):\ +(.*)\n/, '' or
           string_block.gsub! /\A---\ +(\w+)\n(.*?)(?=^---|\z)/m, ''
          key, value = $1, $2
        else
          raise "Failed to parse FakeTestML string:\n#{string_block}"
        end
        block[:points] ||= {}
        block[:points][key] = value

        if key =~ /^(ONLY|SKIP|LAST)$/
          block[key] = true
        end
      end
      array << block
    end
    return array
  end
end
