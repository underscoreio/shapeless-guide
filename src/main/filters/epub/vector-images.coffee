#!/usr/bin/env coffee

images = require '../common/vector-images'
pandoc = require 'pandoc-filter'

pandoc.stdio(images.createFilter("svg"))
