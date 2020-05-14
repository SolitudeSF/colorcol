import os, strutils

const kakSource = slurp "colorcol.kak"

func isHexadecimal(c: char): bool = c in {'0'..'9', 'a'..'f', 'A'..'F'}
func isValid(i: int): bool = i == 4 or i == 5 or i == 7 or i == 9
func hasAlpha(s: string): bool = s.len == 5 or s.len == 9

func colorNormalized(c: string): string {.noinit, inline.} =
  if c.len >= 7: return c[1..^1]
  result = newString((c.len - 1) * 2)
  result[0] = c[1]
  result[1] = c[1]
  result[2] = c[2]
  result[3] = c[2]
  result[4] = c[3]
  result[5] = c[3]
  if c.len == 5:
    result[6] = c[4]
    result[7] = c[4]

func addColor(cmd: var string, line: int, slice: Slice[int], color: string, colorFull, background: bool) =
  cmd.add "set -add buffer colorcol_ranges '"
  cmd.add $line
  cmd.add "."
  cmd.add $(slice.a + 1)
  cmd.add "+"
  cmd.add (if colorFull: $(slice.len - 1) else: "0")
  cmd.add (if background: "|default,rgb" else: "|rgb")
  cmd.add (if color.hasAlpha: "a:" else: ":")
  cmd.add color
  cmd.add "'\n"

func addColor(cmd: var string, line: int, slice: Slice[int], color, marker: string, background: bool) =
  cmd.add "set -add buffer colorcol_replace_ranges '"
  cmd.add $line
  cmd.add "."
  cmd.add $(slice.b + 2)
  cmd.add "+0"
  cmd.add (if background: "|{default,rgb" else: "|{rgb")
  cmd.add (if color.hasAlpha: "a:" else: ":")
  cmd.add color
  cmd.add "}"
  cmd.add marker
  cmd.add "'\n"

func addColor(cmd: var string, color, marker: string, background: bool) =
  cmd.add (if background: "{default,rgb" else: "{rgb")
  cmd.add (if color.hasAlpha: "a:" else: ":")
  cmd.add color
  cmd.add "}'"
  cmd.add marker
  cmd.add "'"

iterator colorSlices(s: string): (int, Slice[int], string) =
  var
    i = 0
    len = 0
    line = 1
    linestart = 0
    start = 0
  while i < s.len:
    if len == 0:
      if s[i] == '#':
        start = i
        len = 1
      elif s[i] == '\n':
        inc line
        linestart = i + 1
    else:
      if s[i].isHexadecimal:
        inc len
      else:
        if len.isValid:
          yield (line, start - linestart..<start - linestart + len,
            s[start..<start + len].colorNormalized)
        if s[i] == '\n':
          inc line
          linestart = i + 1
        len = 0
    inc i
  if len.isValid:
    yield (line, start - linestart..<start - linestart + len,
      s[start..<start + len].colorNormalized)

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
    colorFull = parseBool paramStr 6
    background = parseBool paramStr 7

  if existsFile buffile:
    let data = buffile.readFile
    var
      n = 0
      cmd = ""

    case mode
    of "range":
      cmd.add "unset-option buffer colorcol_ranges\n"
      cmd.add "update-option buffer colorcol_ranges\n"
      for line, slice, color in data.colorSlices:
        cmd.addColor line, slice, color, colorFull, background
    of "replace":
      cmd.add "unset-option buffer colorcol_replace_ranges\n"
      cmd.add "update-option buffer colorcol_replace_ranges\n"
      for line, slice, color in data.colorSlices:
        cmd.addColor line, slice, color, replaceMarker, background
    of "flag":
      var
        matches = 0
        currentLine = 0
      cmd.add "unset-option buffer colorcol_flags\n"
      cmd.add "update-option buffer colorcol_flags\n"
      cmd.add "set -add buffer colorcol_flags "
      for line, _, color in data.colorSlices:
        if line != currentLine:
          matches = 0
          currentLine = line
          cmd.add " "
          cmd.add $line
          cmd.add "|"
        if matches != maxMarks:
          cmd.addColor color, flagMarker, background
          inc matches
    else:
      stderr.writeLine "Unknown mode: " & mode
      quit 1
    stdout.write cmd

main()
