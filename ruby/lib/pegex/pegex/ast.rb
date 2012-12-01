require 'pegex/tree'

class Pegex::Pegex::AST < Pegex::Tree
  def initialize
    @extra_rules = {}
    @prefixes = {
      '!' => ['+asr', -1],
      '=' => ['+asr', 1],
      '.' => '-skip',
      '-' => '-pass',
      '+' => '-wrap',
    }
  end

  def got_grammar(got)
    meta_section, rule_section = got
    grammar =
      {'+toprule' => @toprule}.merge(@extra_rules).merge(meta_section)
    rule_section.each do |rule|
      key, value = rule.first
      grammar[key] = value
    end
    return grammar
  end

  def got_meta_section(got)
    meta = {}
    got.each do |next_|
      key, val = next_
      key = "+#{key}"
      old = meta[key]
      if ! old.nil?
        if old.kind_of? Array
          old << val
        else
          meta[key] = [ old, val ]
        end
      else
        # TODO
      end
    end
    return meta
  end

  def got_rule_definition(got)
    name, value = got
    @toprule = name if name == 'TOP'
    @toprule ||= name
    return { name => value }
  end

  def got_bracketed_group(got)
    prefix, group, suffix = got
    unless prefix.empty?
      group[@prefixes[prefix]] = 1
    end
    unless suffix.empty?
      set_quantity group, suffix
    end
    return group
  end

  def got_all_group(got)
    list = get_group got
    raise unless list.length > 0
    return list.first if list.length == 1
    return { '.all' => list }
  end

  def got_any_group(got)
    list = get_group got
    raise unless list.length > 0
    return list.first if list.length == 1
    return { '.any' => list }
  end

  def get_group(group)
    group.flatten
  end

  def got_rule_part(got)
    rule, sep_op, sep_rule = got
    if sep_rule
      sep_rule['+eok'] = true if sep_op == '%%'
      rule['.sep'] = sep_rule
    end
    return rule
  end

  def got_rule_reference(got)
    prefix, ref1, ref2, suffix = got
    ref = ref1 || ref2 # TODO: determine if ref1 is falsy enough
    node = { '.ref' => ref }
    # TODO
    unless suffix.empty?
      set_quantity node, suffix
    end
    unless prefix.empty?
      if @prefixes[prefix].kind_of? Array
        key, val = @prefixes[prefix]
      else
        key, val = @prefixes[prefix], 1
      end
      node[key] = val
    end
    return node
  end

  def got_regular_expression(got)
    got.gsub!(/\s*#.*\n/, '')
    got.gsub!(/\s+/, '')
    got.gsub!(/\((\:|\=|\!)/, "(?#{$1}")
    return {'.rgx' => got}
  end

  def got_whitespace_token(got)
    XXX got
  end

  def got_error_message(got)
    return { '.err' => got }
  end

  def set_quantity object, quantifier
    case quantifier
    when ?*
      object['+min'] = 0
    when ?+
      object['+min'] = 1
    when ??
      object['+max'] = 1
    when /^(\d+)\+$/
      object['+min'] = $1
    when /^(\d+)\-(\d+)+$/
      object['+min'] = $1
      object['+max'] = $2
    when /^(\d+)$/
      object['+min'] = $1
      object['+max'] = $1
    else
      fail "Invalid quantifier: '#{quantifier}'"
    end
  end

end
