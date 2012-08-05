###
name:      Pegex::Compiler
abstract:  Pegex Compiler
author:    Ingy döt Net <ingy@ingy.net>
license:   perl
copyright: 2011
###

{Parser} = require '../Pegex/Parser'
{Grammar} = require '../Pegex/Pegex/Grammar'
{AST} = require '../Pegex/Pegex/AST'
{Atoms} = require '../Pegex/Grammar/Atoms'

exports.Compiler = class Compiler
  constructor: ->
    @tree = null
    @_tree = null

  compile: (input) ->
    @parse input
    @combinate()
    @native()
    @

  parse: (input) ->
    parser = new Parser new Grammar, new AST
    @tree = parser.parse input
    @

  combinate: (rule) ->
    rule ?= @tree['+toprule']
    return @ unless rule
    @_tree = {}
    for k, v of @tree when k.match /^\+/
      @_tree.k = v
    @

  combinate_rule: (rule) ->
    return if @_tree[rule]?
    object = @_tree[rule] = @tree[rule]
    @combinate_object object

  combinate_object: (object) ->
    if object['.sep']?
      @combinate_object object['.sep']
    if object['.rgx']
      @combinate_re object
    else if object['.ref']?
      rule = object['.ref']
      if @tree[rule]?
        @combinate_rule rule
    else if object['.any']?
      for elem in object['.any']
        @combinate_object elem
    else if object['.all']?
      for elem in object['.all']
        @combinate_object elem
    else if object['.err']
      1
    else
      throw "Can't combinate: #{object}"
    @

  combinate_re: (regexp) ->
    atoms = Atoms.atoms
    re = regexp['.rgx']
    loop
      re = re.replace /(?<!\\)(~+)/g, (m, $1) ->
        '<ws' + $1.length + '>'
      re = re.replace /<(\w+)>/, (m, $1) ->
        if @tree[$1]?
          @tree[$1]['.rgx']
        else if atoms[$1]?
          atoms[$1]
        else
          throw "'#{$1}' not defined in the grammar"
      break if re == regexp['.rgx']
      regexp['.rgx'] = re

  native: ->
    @js_regexes @tree
    @

  js_regexes: (node) ->
    if typeof node == 'object'
      if node instanceof Array
        @js_regexes elem for elem in node
      else
        if node['.rgx']?
          re = node['.rgx']
          node['.rgx'] = new RegExp "^#{re}"
        else
          for key, value of node
            @js_regexes value

  to_yaml: ->
    throw "Pegex.Compiler.to_yaml not yet defined"

  to_json: ->
    JSON.stringify @tree

  to_js: ->
    (require 'util').format @tree
