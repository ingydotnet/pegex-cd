require 'pegex/tree'

class Pegex::Tree::Wrap < Pegex::Tree
  def gotrule got
    return got if @parser.parent['-pass']
    return $pegex_nil unless got
    return @parser.rule => got
  end

  def final got
    return got || {@parser.rule => []}
  end
end
