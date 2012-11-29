module XXX
  def XXX(object)
    require 'psych'
    puts Psych.dump object
    exit
  end

  def YYY(object)
    require 'psych'
    puts Psych.dump object
    return object
  end
end
