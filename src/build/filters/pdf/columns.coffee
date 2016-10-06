#!/usr/bin/env coffee

_      = require 'underscore'
pandoc = require 'pandoc-filter'

action = (type, value, format, meta) ->
  switch type
    when 'Div'
      [ [ident, classes, kvs], body ] = value
      switch classes[0]
        when "row"
          [ head, tail... ] = body
          tailWithSeps = _.chain(tail)
            .map((col) => [ pandoc.RawBlock("latex", "\\columnbreak"), col ])
            .flatten()
            .value()
          return pandoc.Div [ ident, [], kvs ], [
            pandoc.RawBlock("latex", "\\begin{multicols}{#{body.length}}")
            head
            tailWithSeps...
            pandoc.RawBlock("latex", "\\end{multicols}")
          ]

pandoc.stdio(action)
