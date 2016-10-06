#!/usr/bin/env coffee

pandoc = require 'pandoc-filter'

action = (type, value, format, meta) ->
  switch type
    when 'Div'
      [ [ident, classes, kvs], body ] = value
      if classes && classes[0] == "callout"
        environmentName = switch classes[1]
          when "callout-danger"  then "DangerCallout"
          when "callout-warning" then "WarningCallout"
          else "InfoCallout"
        return pandoc.Div [ ident, [], kvs ], [
          pandoc.RawBlock("latex", "\\begin{#{environmentName}}")
          body...
          pandoc.RawBlock("latex", "\\end{#{environmentName}}")
        ]
      else
        return

pandoc.stdio(action)
