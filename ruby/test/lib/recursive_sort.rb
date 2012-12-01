class Object
  def recursive_sort
    self
  end
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
