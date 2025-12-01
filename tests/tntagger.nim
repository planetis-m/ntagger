import std/[unittest, os, strutils, sequtils]

import ntagger

proc tagsLinesForDir(dir: string): seq[string] =
  let tagsText = generateCtagsForDir(dir)
  tagsText.splitLines.filterIt(it.len > 0)

suite "ctags output":
  test "header is extended ctags":
    let tmp = "tests/sample1/"
    let lines = tagsLinesForDir(tmp)
    for line in lines:
      echo "LINE: ", line
    check lines.len >= 4
    check lines[0].startsWith("!_TAG_FILE_FORMAT\t2\t")
    check lines[1].startsWith("!_TAG_FILE_SORTED\t1\t")
    check lines[2].startsWith("!_TAG_PROGRAM_NAME\tntagger\t")

  test "tag lines follow extended format":
    let tmp = "tests/sample1"
    let lines = tagsLinesForDir(tmp)
    # Skip header lines
    let tagLines = lines.filterIt(not it.startsWith("!_TAG_"))
    check tagLines.len > 0

    for line in tagLines:
      let cols = line.split('\t')
      # tagname, filename, ex-command;" and at least one extended field
      check cols.len >= 4
      check cols[0].len > 0
      check cols[1].endsWith(".nim")
      # Third field must end with ;" to be an ex-command
      check cols[2].endsWith(";\"")
      # At least one extended field must specify kind:...
      check cols[3].startsWith("kind:")

    # Ensure specific symbols are present
    let tagsText = generateCtagsForDir(tmp)
    check tagsText.contains("publicProc")
    check tagsText.contains("Foo")
    check tagsText.contains("globalVar")
    check tagsText.contains("myTemplate")
