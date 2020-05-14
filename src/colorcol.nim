import regex, os

const
  kakSource = slurp "colorcol.kak"
  regexHex = re"\b#(?:([[:xdigit:]]{6})(?:[[:xdigit:]]{2})?|([[:xdigit:]]{3})(?:[[:xdigit:]])?)\b"

func addColor(cmd: var string, line: int, slice: Slice[int], color: string, background = true) =
  cmd.add "set -add buffer colorcol_ranges '"
  cmd.add $line
  cmd.add "."
  cmd.add $slice.a
  cmd.add ","
  cmd.add $n
  cmd.add "."
  cmd.add $(slice.b + 1)
  cmd.add (if background: "|default,rgb:" else: "|rgb:")
  cmd.add color
  cmd.add "'\n"

func doubleColor(c: string): string {.noinit, inline.} =
  result = newString(6)
  result[0] = c[0]
  result[1] = c[0]
  result[2] = c[1]
  result[3] = c[1]
  result[4] = c[2]
  result[5] = c[2]

proc main =
  if paramCount() == 0:
    stdout.write kakSource
    quit 0

  let buffile = paramStr 1

  if existsFile buffile:
    var
      n = 0
      cmd = ""

    cmd.add "unset-option buffer colorcol_ranges\nupdate-option buffer colorcol_ranges\n"

    for line in buffile.lines:
      inc n
      for match in line.findAll(regexHex):
        for slice in match.group(0):
          cmd.addColor n, slice, line[slice]
        for slice in match.group(1):
          cmd.addColor n, slice, line[slice].doubleColor
    stdout.write cmd

main()
