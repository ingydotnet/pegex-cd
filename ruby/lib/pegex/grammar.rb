class Pegex
  class Grammar
    attr_accessor :tree

    def initialize
      @tree ||= make_tree
    end

    def make_tree
      {}
    end
  end
end

