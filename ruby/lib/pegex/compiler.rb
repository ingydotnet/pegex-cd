require 'pegex/parser'
require 'pegex/pegex/grammar'
require 'pegex/pegex/ast'
require 'pegex/grammar/atoms'

class Pegex::Compiler
  attr_accessor :tree

  def initialize
    @tree = {}
  end

  def compile
    fail
  end

  def parse input
    parser = Pegex::Parser.new do |p|
      p.grammar = Pegex::Pegex::Grammar.new
      p.receiver = Pegex::Pegex::AST.new
    end

    @tree = parser.parse input

    return self
  end
end
