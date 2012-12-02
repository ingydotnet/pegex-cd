require 'pegex/tree'

class Pegex::Tree::Wrap < Pegex::Tree
  def gotrule got
    return got if @parser.parent['-pass']
    return @parser.rule => got
  end

  def final got
    return got if got
    return @parser.rule => got
  end
end
