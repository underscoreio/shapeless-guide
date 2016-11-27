#!/usr/bin/env coffee

_      = require 'underscore'
pandoc = require 'pandoc-filter'

action = (type, value, format, meta) ->
  switch type
    when 'CodeBlock'
      [ [ident, classes, kvs], body ] = value
      if _.contains(classes, 'scala')
        return pandoc.RawBlock(
          "latex"
          """
          \\begin{lstlisting}[style=scala]
          #{body}
          \\end{lstlisting}
          """
        )

pandoc.stdio(action)