module Pegex
  VERSION = '0.0.1'
end

require 'pegex/parser'
require 'pegex/grammar'

def pegex grammar_text, receiver=nil
  unless receiver
    require 'pegex/tree/wrap'
    receiver = Pegex::Tree::Wrap.new
  end
  receiver = receiver.new if receiver.class == Class
  return Pegex::Parser.new { |o|
    o.grammar = Pegex::Grammar.new {|g| g.text = grammar_text}
    o.receiver = receiver
  }
end
