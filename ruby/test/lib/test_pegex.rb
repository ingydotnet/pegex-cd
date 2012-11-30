require 'pegex/compiler'

module TestPegex
  def compile(grammar_text)
    puts "Parsing this Pegex grammar:"
    puts grammar_text
    puts
    return Pegex::Compiler.new.parse(grammar_text).tree
  end

  def yaml(object)
    require 'psych'
    Psych.dump(object)
  end

  def clean(yaml)
    yaml.sub!(/\A---\s/, '')
    return yaml.gsub(/'(\d+)'/, '\1')
  end
end
