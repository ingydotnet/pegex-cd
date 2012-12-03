$:.unshift File.dirname(__FILE__)
$:.unshift File.dirname(__FILE__) + '/../../lib'

require 'test/unit'

module FakeTestMLRunner
end

def caller_name
  name = caller.last.split(':').first.gsub(/[^\w]+/, '_')
end

def testml_run &runner
  name = caller_name
  $testml_runners ||= {}
  $testml_runners[name] = runner
  FakeTestMLRunner.module_eval <<"..."
def test_#{name}
  return if self.class == FakeTestML
  run_runner '#{name}'
end
...
end

def testml_data data
  name = caller_name
  $testml_data ||= {}
  $testml_data[name] = data
end

class FakeTestML < Test::Unit::TestCase
  require 'xxx'; include XXX # XXX

  def run_runner name
    @test_name = name
    $testml_runners[name].call(self)
  end

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
    raise "No testml data provided" unless $testml_data[@test_name]
    data $testml_data[@test_name]
  end

  def label text
    @label = text
  end

  def loop expr, callback=nil
    assert_testml
    callback ||= method 'run_test'
    get_blocks(expr).each do |block|
      $error = nil
      callback.call(block, expr)
      raise $error if $error
    end
  end

  def run_test block, expr
    # puts block[:title]
    block = get_blocks(expr, [block]).first or return
    evaluate expr, block
  end

  def assert_equal got, want, block
    if got != want
      on_fail if respond_to? 'on_fail'
      File.open('/tmp/got', 'w') {|f| f.write got}
      File.open('/tmp/want', 'w') {|f| f.write want}
      puts `diff -u /tmp/want /tmp/got`
    end
    super want, got, block[:title]
  end

  def assert_match got, want, block
    super want, got, block[:title]
  end

  def Catch any=nil
    fail "Catch called, but no error occurred" unless $error
    error = $error
    $error = nil
    return error.message
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
    # TODO @error
    return if $error and func != 'Catch'
    return args.first if func.empty?
    args << block if func =~ /^assert_/
    begin
      return method(func).call(*args)
    rescue => e
      $error = e
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
