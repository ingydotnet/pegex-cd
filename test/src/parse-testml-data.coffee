exports.parse_testml_data = (text) ->
  data = []
  if not text.match /^===/
    throw "Bad data"
  while text.length
    prev = text
    text = text.replace /(===[\s\S]*?\n)(?====)/, ''
    if text == prev
      section = prev
      text = ''
    else
      section = RegExp.$1
    block = {}
    section = section.replace /\n*$/, "\n"
    label = (section.match /^=== (.*)/)[1]
    continue if not label
    block.label = label
    section = section.replace /[\s\S]*?(?=\n---)\n/, ''
    while section.match /^---/
      prev = section
      section = section.replace /^--- (\w+)\n([\s\S]*?)(?=(\n$|\n---))/, ''
      if prev != section
        block[RegExp.$1] = RegExp.$2 + "\n"
      else
        section = section.replace /^--- (\w+):\s+(.*?)\s*\n/m, ''
        if prev != section
          block[RegExp.$1] = RegExp.$2
        else
          xxx "Bad section: #{section}"
      section = section.replace /[\s\S]*?(?=\n---)\n/, ''

    data.push block
  data

