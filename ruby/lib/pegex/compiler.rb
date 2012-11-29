require 'pegex/parser'
require 'pegex/pegex/grammar'
require 'pegex/pegex/ast'
require 'pegex/grammar/atoms'

class Pegex
  class Compiler
    attr_accessor :tree

    def initialize
      @tree = {}
    end

    def compile
      throw
    end

    def parse(input)
      parser = Parser.new do |p|
        p.grammar = Pegex::Grammar.new
        p.receiver = Pegex::AST.new
      end

      @tree = parser.parse(input)

      return self
    end
  end
end
