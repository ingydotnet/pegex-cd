require 'pegex/parser'
require 'pegex/grammar'

class Pegex
  require 'xxx'; include XXX; # XXX
  module Export
    def pegex grammar_text, receiver=nil
      unless receiver
        require 'pegex/tree/wrap'
        receiver = Tree::Wrap.new
      end
      receiver = receiver.new if receiver.class == Class
      return Parser.new { |o|
        o.grammar = Grammar.new {|g| g.text = grammar_text}
        o.receiver = receiver
      }
    end
  end
end
