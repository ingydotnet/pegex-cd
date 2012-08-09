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

startTime   = Date.now()
currentFile = null
passedTests = 0
failures    = []

global[name] = func for name, func of require 'assert'

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
args = process.argv.slice(2)
files = if args.length then args else fs.readdirSync 'test'
for file in files when file.match /\.coffee$/i
  if not file.match /^x?test\//
    currentFile = filename = path.join 'test', file
  else
    currentFile = filename = file
  code = fs.readFileSync filename
  try
    CoffeeScript.run code.toString(), {filename}
  catch error
    failures.push {filename, error}

return not failures.length
