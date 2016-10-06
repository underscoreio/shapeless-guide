#!/usr/bin/env coffee

merge  = require '../common/merge-code'
pandoc = require 'pandoc-filter'

merge.stdioComplete(merge.createFilter())
