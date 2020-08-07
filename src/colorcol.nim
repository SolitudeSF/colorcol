import os, strutils

const kakSource = slurp "colorcol.kak"

type Color = array[6, char]

func isHexadecimal(c: char): bool = c in {'0'..'9', 'a'..'f', 'A'..'F'}
func isValid(i: int): bool = i == 4 or i == 5 or i == 7 or i == 9

func normalizedColor(str: string, start, len: int): Color {.inline.} =
  if len >= 6:
    copyMem addr result, unsafeAddr str[start], sizeof Color
  else:
    result[0] = str[start]
    result[1] = str[start]
    result[2] = str[start + 1]
    result[3] = str[start + 1]
    result[4] = str[start + 2]
    result[5] = str[start + 2]

func add(s: var string, a: openArray[char]) =
  let l = s.len
  s.setLen(s.len + a.len)
  copyMem addr s[l], unsafeAddr a[0], a.len

func addColor(cmd: var string, line: int, slice: Slice[int],
  color: Color, style: string, colorFull: bool) =
  cmd.add "set -add buffer colorcol_ranges '"
  cmd.add $line
  cmd.add "."
  cmd.add $(slice.a + 1)
  if colorFull:
    cmd.add "+"
    cmd.add $slice.len
  else:
    cmd.add "+1"
  cmd.add style
  cmd.add color
  cmd.add "'\n"

func addColor(cmd: var string, line: int, slice: Slice[int], color: Color, marker: string) =
  cmd.add "set -add buffer colorcol_replace_ranges '"
  cmd.add $line
  cmd.add "."
  cmd.add $(slice.b + 2)
  cmd.add "+0|{rgb:"
  cmd.add color
  cmd.add "}"
  cmd.add marker
  cmd.add "'\n"

func addColor(cmd: var string, color: Color, marker: string) =
  cmd.add "{rgb:"
  cmd.add color
  cmd.add "}"
  cmd.add marker

iterator colorSlices(s: string): (int, Slice[int], Color) =
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
        if not s[i].isAlphaNumeric and len.isValid:
          yield (line, start - linestart..<start - linestart + len,
            normalizedColor(s, start + 1, len))
        if s[i] == '\n':
          inc line
          linestart = i + 1
        len = 0
    inc i
  if len.isValid:
    yield (line, start - linestart..<start - linestart + len,
      normalizedColor(s, start + 1, len))

proc main =
  if paramCount() == 0:
    stdout.write kakSource
    quit 0

  let
    mode = paramStr 1
    maxMarks = parseInt paramStr 2
    flagMarker = paramStr 3
    appendMarker = paramStr 4
    colorFull = parseBool paramStr 5
    style = if mode == "background": "|default,rgb:" else: "|rgb:"

  let data = stdin.readAll
  var
    n = 0
    cmd = ""

  case mode
  of "background", "foreground":
    cmd.add "unset-option buffer colorcol_ranges\n"
    cmd.add "update-option buffer colorcol_ranges\n"
    for line, slice, color in data.colorSlices:
      cmd.addColor line, slice, color, style, colorFull
  of "append":
    cmd.add "unset-option buffer colorcol_replace_ranges\n"
    cmd.add "update-option buffer colorcol_replace_ranges\n"
    for line, slice, color in data.colorSlices:
      cmd.addColor line, slice, color, appendMarker
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
        cmd.addColor color, flagMarker
        inc matches
  else:
    stderr.writeLine "Unknown mode: " & mode
    quit 1
  stdout.write cmd

main()
