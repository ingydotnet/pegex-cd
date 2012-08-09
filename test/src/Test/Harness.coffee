# Log a message with a color.
global.log = (message, color, explanation) ->
  console.log color + message + reset + ' ' + (explanation or '')
# Easy print
global.say = console.log
# Debugging
global.xxx = ->
  console.log.apply console, arguments
  process.exit(0)

fs            = require 'fs'
path          = require 'path'
CoffeeScript  = require 'coffee-script'
{exec}        = require 'child_process'

# ANSI Terminal Colors.
enableColors = no
unless process.platform is 'win32'
  enableColors = not process.env.NODE_DISABLE_COLORS

bold = red = green = reset = ''
if enableColors
  bold  = '\x1B[0;1m'
  red   = '\x1B[0;31m'
  green = '\x1B[0;32m'
  reset = '\x1B[0m'

startTime   = Date.now()
currentFile = null
passedTests = 0
failures    = []

global[name] = func for name, func of require 'assert'

# Convenience aliases.
global.CoffeeScript = CoffeeScript

# Our test helper function for delimiting different test cases.
global.test = (description, fn) ->
  try
    fn.test = {description, currentFile}
    fn.call(fn)
    ++passedTests
  catch e
    e.description = description if description?
    e.source      = fn.toString() if fn.toString?
    failures.push filename: currentFile, error: e

# See http://wiki.ecmascript.org/doku.php?id=harmony:egal
egal = (a, b) ->
  if a is b
    a isnt 0 or 1/a is 1/b
  else
    a isnt a and b isnt b

# A recursive functional equivalence helper; uses egal for testing equivalence.
arrayEgal = (a, b) ->
  if egal a, b then yes
  else if a instanceof Array and b instanceof Array
    return no unless a.length is b.length
    return no for el, idx in a when not arrayEgal el, b[idx]
    yes

global.eq      = (a, b, msg) -> ok egal(a, b), msg
global.arrayEq = (a, b, msg) -> ok arrayEgal(a,b), msg

# When all the tests have run, collect and print errors.
# If a stacktrace is available, output the compiled function source.
process.on 'exit', ->
  time = ((Date.now() - startTime) / 1000).toFixed(2)
  message = "passed #{passedTests} tests in #{time} seconds#{reset}"
  return log(message, green) unless failures.length
  log "failed #{failures.length} and #{message}", red
  for fail in failures
    {error, filename}  = fail
    jsFilename         = filename.replace(/\.coffee$/,'.js')
    match              = error.stack?.match(new RegExp(fail.file+":(\\d+):(\\d+)"))
    match              = error.stack?.match(/on line (\d+):/) unless match
    [match, line, col] = match if match
    console.log ''
    log "  #{error.description}", red if error.description
    log "  #{error.stack}", red
    log "  #{jsFilename}: line #{line ? 'unknown'}, column #{col ? 'unknown'}", red
    console.log "  #{error.source}" if error.source
  return

# Run every test requested, recording failures.
exports.run = (paths) ->
  paths ?= process.argv.slice(2)
  paths = ['test'] if not paths.length
  files = []
  find = (path) ->
    try
      stat = fs.lstatSync path
    catch error
      return
    if stat.isFile()
      if path.match /\.coffee$/i
        # XXX this is a local hack
        if not path.match /\/src\//
          files.push path
    else if stat.isDirectory()
      for p in fs.readdirSync(path)
        find path + '/' + p

  for path in paths
    find path

  for file in files
    currentFile = filename = file
    code = String fs.readFileSync filename
    try
      require.main = {}
      CoffeeScript.run code, {filename}
    catch error
      failures.push {filename, error}

  return not failures.length
