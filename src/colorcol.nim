import regex, os, strutils

const
  kakSource = slurp "colorcol.kak"
  regexHex = re"\b#(?:([[:xdigit:]]{6})(?:[[:xdigit:]]{2})?|([[:xdigit:]]{3})(?:[[:xdigit:]])?)\b"

func addColor(cmd: var string, line: int, slice: Slice[int], color: string, background = true) =
  cmd.add "set -add buffer colorcol_ranges '"
  cmd.add $line
  cmd.add "."
  cmd.add $slice.a
  cmd.add "+"
  cmd.add $slice.len
  cmd.add (if background: "|default,rgb:" else: "|rgb:")
  cmd.add color
  cmd.add "'\n"

func addColor(cmd: var string, line: int, slice: Slice[int], color, marker: string, background = false) =
  cmd.add "set -add buffer colorcol_replace_ranges '"
  cmd.add $line
  cmd.add "."
  cmd.add $(slice.b + 2)
  cmd.add "+0"
  cmd.add (if background: "|{default,rgb:" else: "|{rgb:")
  cmd.add color
  cmd.add "}"
  cmd.add marker
  cmd.add "'\n"

func addColor(cmd: var string, color, marker: string, background = false) =
  cmd.add (if background: "{default,rgb:" else: "{rgb:")
  cmd.add color
  cmd.add "}"
  cmd.add marker

func longColor(c: string): string {.noinit, inline.} =
  result = newString(c.len * 2)
  result[0] = c[0]
  result[1] = c[0]
  result[2] = c[1]
  result[3] = c[1]
  result[4] = c[2]
  result[5] = c[2]
  if c.len == 4:
    result[6] = c[3]
    result[7] = c[3]

proc main =
  if paramCount() == 0:
    stdout.write kakSource
    quit 0

  let
    buffile = paramStr 1
    mode = paramStr 2
    maxMarks = parseInt paramStr 3
    flagMarker = paramStr 4
    replaceMarker = paramStr 5

  stderr.writeLine "Colorcol mode: ", mode

  if existsFile buffile:
    var
      n = 0
      cmd = ""

    case mode
    of "range":
      cmd.add "unset-option buffer colorcol_ranges;update-option buffer colorcol_ranges\n"
      for line in buffile.lines:
        inc n
        for match in line.findAll(regexHex):
          for slice in match.group(0):
            cmd.addColor n, slice, line[slice]
          for slice in match.group(1):
            cmd.addColor n, slice, line[slice].longColor
    of "replace":
      cmd.add "unset-option buffer colorcol_replace_ranges;update-option buffer colorcol_replace_ranges\n"
      for line in buffile.lines:
        inc n
        for match in line.findAll(regexHex):
          for slice in match.group(0):
            cmd.addColor n, slice, line[slice], replaceMarker
          for slice in match.group(1):
            cmd.addColor n, slice, line[slice].longColor, replaceMarker
    of "flag":
      var
        matches = 0
        lineMarked = false

      cmd.add "unset-option buffer colorcol_flags;update-option buffer colorcol_flags\n"
      cmd.add "set -add buffer colorcol_flags "
      for line in buffile.lines:
        inc n
        matches = 0
        lineMarked = false
        for match in line.findAll(regexHex):
          if not lineMarked:
            lineMarked = true
            cmd.add " "
            cmd.add $n
            cmd.add "|"
          for slice in match.group(0):
            cmd.addColor line[slice], flagMarker
          for slice in match.group(1):
            cmd.addColor line[slice].longColor, flagMarker
          inc matches
          if matches == maxMarks: break
    else:
      stderr.writeLine "Unknown mode: " & mode
      quit 1
    stdout.write cmd

main()
