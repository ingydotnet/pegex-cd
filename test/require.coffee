modules = [
  'Pegex'
  'Pegex/Compiler'
  'Pegex/Grammar'
  'Pegex/Input'
  'Pegex/Parser'
  'Pegex/Receiver'
  'Pegex/Grammar/Atoms'
  'Pegex/Parser/Indent'
  'Pegex/Pegex/AST'
  'Pegex/Pegex/Grammar'
]

for module in modules
  test "Can require #{module}", ->
    ok require "../lib/#{module}"

# vim:set ts=8 sw=2 sts=2:
