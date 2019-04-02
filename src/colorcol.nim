import regex, os

const
  kak_source = slurp "colorcol.kak"
  regexHex = re"[0-9A-Fa-f]{6}"

template addLineColor(number: int, color, marker: string) =
  stdout.write " ", number, "|{rgb:", color, "}", marker

if paramCount() == 0:
  stdout.write kak_source
  quit 0

let
  timestamp = paramStr 1
  buffile = paramStr 2
  marker = paramStr 3

var
  n = 0
  match: RegexMatch

stdout.write "set-option buffer colorcol_marks ", timestamp

if existsFile buffile:
  for line in buffile.lines:
    inc n
    if line.find(regexHex, match):
      addLineColor n, line[match.boundaries], marker
