require 'pegex/compiler'

class Object
  def recursive_sort; self end
end

class Array
  def recursive_sort
    map &:recursive_sort
  end
end

class Hash
  def recursive_sort
    Hash[keys.sort.map {|k| [k, self[k].recursive_sort]}]
  end
end

module TestPegex
  def compile(grammar_text)
    tree = Pegex::Compiler.new.parse(grammar_text).tree
    tree.delete('+toprule')
    return tree
  end

  def on_fail
    puts "Parsing this Pegex grammar:"
    puts grammar_text
    puts
  end

  def yaml(object)
    require 'psych'
    Psych.dump(object.recursive_sort)
  end

  def clean(yaml)
    yaml.sub!(/\A---\s/, '')
    return yaml.gsub(/'(\d+)'/, '\1')
  end
end
