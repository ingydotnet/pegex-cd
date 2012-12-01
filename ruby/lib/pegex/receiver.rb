$pegex_nil = []

class Pegex::Receiver
  attr_accessor :parser

  def flatten array
    return array.flatten!
  end
end
