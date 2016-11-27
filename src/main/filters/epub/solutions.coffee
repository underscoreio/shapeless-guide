#!/usr/bin/env coffee

solutions = require '../common/solutions'
pandoc    = require 'pandoc-filter'

pandoc.stdio(solutions.createFilter())
