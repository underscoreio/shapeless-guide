'use strict'

pandoc = require 'pandoc-filter'

mkListingsEnvironment = (code) ->
  return pandoc.RawBlock('latex', "\\begin{lstlisting}[style=scala]\n" + code + "\n\\end{lstlisting}\n")

action = (type, value, format, meta) ->
  switch type
    when 'CodeBlock'
      [ [ident, classes, kvs], body ] = value
      if 'scala' in classes
        return mkListingsEnvironment(body)

module.exports = {
  action
}
