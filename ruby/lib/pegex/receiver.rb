$pegex_nil = []

class Pegex
  class Receiver
    attr_accessor :parser

    def flatten(array)
      return array.flatten!
    end
  end
end
