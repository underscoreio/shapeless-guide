'use strict'

pandoc = require 'pandoc-filter'

# String helpers --------------------------------

last = null

areMergeable = (a, b) ->
  if a.t == 'CodeBlock' && b.t == 'CodeBlock'
    aLang = a.c[0][1][0]?
    bLang = b.c[0][1][0]?
    aLang == bLang
  else
    false

mergeTwo = (a, b) ->
  pandoc.CodeBlock(a.c[0], a.c[1] + "\n\n" + b.c[1])

mergeAll = (blocks, accum = []) ->
  switch blocks.length
    when 0 then accum
    when 1 then accum.concat(blocks)
    else
      [ a, b, tail... ] = blocks
      if areMergeable(a, b)
        mergeAll([ mergeTwo(a, b) ].concat(tail), accum)
      else
        mergeAll([ b ].concat(tail), accum.concat([ a ]))

createFilter = () ->
  return (type, value, format, meta) ->
    switch type
      when 'Pandoc'
        [ meta, blocks ] = value
        return { t: 'Pandoc', c: [ meta, mergeAll(blocks) ] }
      when 'BlockQuote'
        blocks = value
        return pandoc.BlockQuote(mergeAll(blocks))
      when 'Div'
        [ attr, blocks ] = value
        return pandoc.Div(attr, mergeAll(blocks))
      when 'Note'
        blocks = value
        return pandoc.Note(mergeAll(blocks))
      when 'ListItem'
        [ blocks ] = value
        return pandoc.ListItem(mergeAll(blocks))
      when 'Definition'
        [ blocks ] = value
        return pandoc.Definition(mergeAll(blocks))
      when 'TableCell'
        [ blocks ] = value
        return pandoc.TableCell(mergeAll(blocks))

# Rewrite of pandoc.stdio
# that treats the top-level Pandoc as a single element
# so we can merge code blocks at the top level -.-
stdioComplete = (action) ->
  stdin = require('get-stdin')
  stdin (json) ->
    data   = JSON.parse(json)
    format = if process.argv.length > 2 then process.argv[2] else ''
    temp   = pandoc.filter(data, action, format)
    # console.error(new Error(JSON.stringify(temp)))
    output = [ { unMeta: temp[0].unMeta }, mergeAll(temp[1]) ]
    process.stdout.write(JSON.stringify(output))
    return

module.exports = {
  createFilter
  stdioComplete
}
