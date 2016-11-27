#!/usr/bin/env coffee

_      = require 'underscore'
pandoc = require 'pandoc-filter'

action = (type, value, format, meta) ->
  if type == 'Header'
    [ level, [ident, classes, kvs], body ] = value

    # Remove "solutions" heading from the document:
    if ident == "solutions" then return []
  else if type == 'Div'
    [ [ident, classes, kvs], body ] = value

    # Remove "solutions" div from the document:
    if classes?[0] == "solutions" then return []

    return

pandoc.stdio(action)
