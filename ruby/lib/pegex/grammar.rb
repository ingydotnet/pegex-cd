require 'pegex'
class Pegex::Grammar
  require 'xxx'; include XXX # XXX

  attr_accessor :text

  def initialize
    yield self if block_given?
    @tree ||= make_tree
  end

  def tree
    return @tree if @tree
    fail "Can't create a #{self.class} grammar. No grammar text" unless @text
    return @tree = make_tree
  end

  def make_tree
    require 'pegex/compiler'
    return @tree = Pegex::Compiler.new.compile(@text).tree
  end
end

