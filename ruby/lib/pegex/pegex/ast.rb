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
    # XXX [meta_section, rule_section]
    grammar =
      {'+toprule' => @toprule}.merge(@extra_rules).merge(meta_section)
    rule_section.each do |rule|
      key, value = rule
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
    # TODO
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
    ref = ref1 || ref2
    node = { '.ref' => ref }
    # TODO
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
    XXX got
  end
end
