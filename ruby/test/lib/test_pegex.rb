require './test/lib/testml-fake'
require 'pegex/compiler'
require 'recursive_sort'

require 'xxx'; # XXX

class TestPegex < TestML::Fake
  include TestML::Fake::TestCases

  def compile grammar_text
    $grammar_text = grammar_text
    tree = Pegex::Compiler.new.parse(grammar_text).combinate.tree
    tree.delete '+toprule'
    return tree
  end

  def yaml object
    require 'psych'
    Psych.dump object.recursive_sort
  end

  def clean yaml
    yaml.sub! /^\.\.\.\n/, ''
    yaml.sub! /\A---\s/, ''
    yaml.gsub! /'(\d+)'/, '\1'
    yaml.gsub! /\+eok: true/, '+eok: 1'
    return yaml
  end

  def on_fail
    puts "Parsing this Pegex grammar:"
    puts $grammar_text
    puts
  end
end
