fs            = require 'fs'
path          = require 'path'
CoffeeScript  = require 'coffee-script'
{exec} = require 'child_process'

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

task 'build', 'build the Pegex framework', build = (cb) ->
  exec 'coffee --compile --output lib/ src/', (err) ->
    throw err if err

task 'test', 'run the Pegex test suite', ->
  runTests CoffeeScript

# Run the CoffeeScript test suite.
runTests = (CoffeeScript) ->
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

  # Run every test in the `test` folder, recording failures.
  files = fs.readdirSync 'test'
  for file in files when file.match /\.coffee$/i
    currentFile = filename = path.join 'test', file
    code = fs.readFileSync filename
    try
      CoffeeScript.run code.toString(), {filename}
    catch error
      failures.push {filename, error}
  return !failures.length

# Log a message with a color.
log = (message, color, explanation) ->
  console.log color + message + reset + ' ' + (explanation or '')

# Debugging
xxx = ->
  console.log arguments
  process.exit(0)

# vim:set ts=8 sw=2 sts=2:
