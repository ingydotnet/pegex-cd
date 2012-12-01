module XXX
  def XXX object
    require 'psych'
    puts Psych.dump object
    puts 'XXX from: ' + caller.first
    exit
  end

  def YYY object, show_caller=true
    require 'psych'
    puts Psych.dump object
    puts 'YYY from: ' + caller.first if show_caller
    return object
  end
end
