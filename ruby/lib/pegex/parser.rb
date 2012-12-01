require 'pegex/input'

require 'xxx'

class Pegex
  class Parser
    include XXX

    attr_accessor :grammar
    attr_accessor :receiver
    attr_accessor :parent
    attr_accessor :rule

    $dummy = [1]

    def initialize
      @position = 0
      @farthest = 0
      @optimized = false
      @debug = false
      # @debug = true
      yield self
    end

    def parse(input, start=nil)
      @position = 0
      if input.kind_of?(String)
        input = Input.new do |i|
          i.string = input
        end
      end
      @input = input
      @input.open unless @input.open?
      @buffer = @input.read
      @length = @buffer.length

      raise "No 'grammar'. Can't parse" unless @grammar
      @tree = @grammar.tree ||= @grammar.make_tree

      start_rule_ref = start ||
        @tree['+toprule'] ||
        (@tree['TOP'] ? 'TOP' : nil) or
          raise "No starting rule for Pegex::Parser::parse"

      optimize_grammar(start_rule_ref)

      raise  "No 'receiver'. Can't parse" unless @receiver

      # XXX does ruby have problems with circulat references
      @receiver.parser = self

      if @receiver.respond_to?('initial')
        @rule, @parent = $start_rule_ref, {}
      end

      match = match_ref start_rule_ref, {}

      @input.close

      if !match or @position < @length
        throw_error "Parse document failed for some reason"
        return
      end

      if @receiver.respond_to?('final')
        @rule, @parent = start_rule_ref, {}
        match = [ @receiver.final(match.first) ]
      end

      return match.first
    end

    def optimize_grammar(start)
      return if @optimized
      @tree.each_pair do |name, node|
        next if node.kind_of?(String)
        optimize_node node
      end
      optimize_node({'.ref' => start})
      @optimized = true
    end

    def optimize_node(node)
      ['ref', 'rgx', 'all', 'any', 'err', 'code', 'xxx'].each do |kind|
        raise if kind == 'xxx'
        if node['rule'] = node[".#{kind}"]
          node['kind'] = kind
          node['method'] = self.method "match_#{kind}"
          break
        end
      end
      min, max = node.values_at '+min', '+max'
      node['+min'] ||= max == nil ? 1 : 0
      node['+max'] ||= min == nil ? 1 : 0
      node['+asr'] ||= nil
      node['+min'] = node['+min'].to_i
      node['+max'] = node['+max'].to_i

      if ['any', 'all'].include? node['kind']
        node['rule'].each do |elem|
          optimize_node elem
        end
      elsif node['kind'] == 'ref'
        ref = node['rule']
        rule = @tree[ref]
        if @receiver.respond_to?("got_#{ref}")
          rule['action'] = receiver.method "got_#{ref}"
        elsif receiver.respond_to? 'gotrule'
          rule['action'] = receiver.method 'gotrule'
        end
        node['method'] = self.method 'match_ref_trace' if @debug
      elsif node['kind'] == 'rgx'
        node['rule'] = Regexp.new("\\A#{node['.rgx']}")
      end
      if sep = node['.sep']
        optimize_node sep
      end
    end

    def match_next(next_)
      return match_next_with_sep(next_) if next_['.sep']

      rule, method, kind, min, max, assertion =
        next_.values_at 'rule', 'method', 'kind', '+min', '+max', '+asr'

      position, match, count = @position, [], 0

      while return_ = method.call(rule, next_)
        position = @position unless assertion
        count += 1
        match.concat return_
        break if max == 1
      end
      if max != 1
        match = [match]
        if ((@position = position) > @farthest)
          @farthest = position
        end
      end
      result = (count >= min and (max == 0 or count <= max)) ^ (assertion == -1)
      if (not result or assertion)
        if ((@position = position) > @farthest)
          @farthest = position
        end
      end

      return (result ? next_['-skip'] ? [] : match : false)
    end

    def match_next_with_sep(next_)
      rule, method, kind, min, max, sep =
        next_.values_at 'rule', 'method', 'kind', '+min', '+max', '.sep'

      position, match, count, scount, smin, smax =
        @position, [], 0, 0, sep.values_at('+min', '+max')

      while return_ = method.call(rule, next_)
        position = @position
        count += 1
        match.concat return_
        return_ = match_next(sep) or break
        match.concat return_
        scount += 1
      end
      if max != 1
        match = [match]
      end
      result = (count >= min and (max == 0 or count <= max))
      if count == scount and not sep['+eok']
        if ((@position = position) > @farthest)
          @farthest = position
        end
      end

      return (result ? next_['-skip'] ? [] : match : false)
    end

    def match_ref(ref, parent)
      rule = @tree[ref]
      match = match_next(rule) or return false
      return $dummy unless rule['action']
      @rule, @parent = ref, parent
      [ rule['action'].call(match.first) ]
    end

    def match_rgx(regexp, parent=nil)
      position = @position
      string = @buffer[position .. -1]
      (m = string.match regexp) or return false
      position += m[0].length
      match = m[1..-1]
      match = [ match ] if m.length > 2
      if (@position = position) > @farthest
        @farthest = position
      end
      return match
    end

    def match_all(list, parent=nil)
      position, set, len = @position, [], 0
      list.each do |elem|
        if (match = match_next(elem))
          if !elem['+asr'] and !elem['-skip']
            set.concat match
            len += 1
          end
        else
          if (@position = position) > @farthest
            @farthest = position
          end
          return false
        end
      end
      set = [set] if len > 1
      return set
    end

    def match_any(list, parent=nil)
      list.each do |elem|
        if (match = match_next elem)
          return match
        end
      end
      return false
    end

    def match_err(error, parent=nil)
      throw_error error
    end

    def match_ref_trace(ref, parent)
      rule = @tree[ref]
      trace_on = (! rule['+asr'])
      trace("try_#{ref}") if trace_on
      result = nil
      if (result = match_ref(ref, parent))
        trace("got_#{ref}") if trace_on
      else
        trace("not_#{ref}") if trace_on
      end
      return result
    end

    def trace(action)
      indent = !!(action.match(/^try_/))
      @indent ||= 0
      @indent -= 1 unless indent
      $stderr.print ' ' * @indent
      @indent += 1 if indent
      snippet = @buffer[@position..-1]
      snippet = snippet[0..30] + '...' if snippet.length > 30;
      snippet.gsub!(/\n/, "\\n")
      $stderr.printf "%-30s", action
      $stderr.print (indent ? " >#{snippet}<\n" : "\n")
    end

    def throw_error(msg)
      raise msg
    end
  end
end
