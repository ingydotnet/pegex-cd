require 'pegex/input'

require 'xxx'

class Pegex
  class Parser
    include XXX

    attr_accessor :grammar
    attr_accessor :receiver

    $dummy = [1]

    def initialize
      @position = 0
      @farthest = 0
      @optimized = false
      @debug = false
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
      node['+min'] ||= defined?(max) ? 0 : 1
      node['+max'] ||= defined?(min) ? 0 : 1
      node['+asr'] ||= nil

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
    end

    def match_ref(ref, parent)
      rule = @tree[ref]
      match = match_next(rule) or return false
      return $dummy unless rule['action']
      @rule, @parent = ref, parent
      [ rule['action'].call(@receiver, match.first) ]
    end

    def match_rgx
    end

    def match_all(list, parent=nil)
    end

    def match_any
    end

    def match_err
    end

    def throw_error(msg)
      raise msg
    end
  end
end
