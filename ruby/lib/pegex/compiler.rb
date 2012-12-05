require 'pegex/parser'
require 'pegex/pegex/grammar'
require 'pegex/pegex/ast'
require 'pegex/grammar/atoms'

class Pegex::Compiler
  attr_accessor :tree

  def initialize
    @tree = {}
    @_tree = {}
    @atoms = Pegex::Grammar::Atoms.new.atoms
  end

  def compile grammar
    parse grammar
    combinate
    native
    return self
  end

  def parse input
    parser = Pegex::Parser.new do |p|
      p.grammar = Pegex::Pegex::Grammar.new
      p.receiver = Pegex::Pegex::AST.new
    end

    @tree = parser.parse input

    return self
  end

  def combinate rule=nil
    (rule ||= @tree['+toprule']) or return self

    @tree.keys.grep(/^\+/).each {|k| @_tree[k] = @tree[k]}

    combinate_rule rule
    @tree = @_tree
    return self
  end

  def combinate_rule rule
    return if @_tree[rule]
    object = @_tree[rule] = @tree[rule]
    combinate_object object
  end

  def combinate_object object
    if (sub = object['.sep'])
      combinate_object sub
    end
    if object['.rgx']
      combinate_re object
    elsif (rule = object['.ref'])
      if @tree[rule]
        combinate_rule rule
      end
    elsif object['.any']
      object['.any'].each {|elem| combinate_object elem}
    elsif object['.all']
      object['.all'].each {|elem| combinate_object elem}
    elsif object['.err']
    else
      puts "Can't combinate:"
      XXX object
    end
  end

  def combinate_re regex
    re = regex['.rgx'].clone
    loop do
      re.gsub! /(~+)/ do |m|
        "<ws#{$1.length}>"
      end
      re.gsub! /<(\w+)>/ do |m|
        if @tree[$1]
          @tree[$1]['.rgx'] or fail "'#{$1}' not defined as a single RE"
        else
          @atoms[$1] or fail "'#{$1}' not defined in the grammar"
        end
      end
      break if re == regex['.rgx']
      regex['.rgx'] = re.clone
    end
  end

  def native
    # TODO
  end
end
