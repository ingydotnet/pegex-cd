require 'pegex/input'

require 'xxx'

class Pegex
  class Parser
    include XXX

    attr_accessor :grammar
    attr_accessor :receiver

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
  end
end
