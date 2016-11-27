#!/usr/bin/env coffee

_      = require 'underscore'
pandoc = require 'pandoc-filter'

# Because we wrap the table we're processing in a <div>,
# the walk algorithm causes us to revisit when processing
# the children of the <div>. We "hash" (stringify) visited
# tables and cache them here to prevent infinite recursion.
visited = []

action = (type, value, format, meta) ->
  switch type
    when 'Table'
      hash = JSON.stringify(value)
      unless _.contains(visited, hash)
        visited.push(hash)
        pandoc.Div [ "", [ "table-responsive" ], [] ], [
          pandoc.Table.apply(this, value)
        ]

pandoc.stdio(action)
