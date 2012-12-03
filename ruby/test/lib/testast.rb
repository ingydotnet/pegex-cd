require 'pegex/tree'

class TestAST < Pegex::Tree
  def got_zero got
    return 0
  end

  def got_empty got
    return ''
  end

  def got_undef got
    return nil
  end
end
