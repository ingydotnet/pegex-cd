class Pegex::Grammar
  require 'xxx'; include XXX # XXX

  attr_accessor :text
  attr_accessor :tree

  def initialize
    yield self if block_given?
    @tree ||= make_tree
  end

  def make_tree
    unless @text
      fail "Can't create a #{self.class} grammar. No grammar text"
    end
    require 'pegex/compiler'
    return Pegex::Compiler.new.compile(@text).tree
  end
end

