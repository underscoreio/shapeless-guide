#global module:false

"use strict"

ebook = require 'underscore-ebook-template'

module.exports = (grunt) ->
  ebook(grunt, {
    dir: {
      lib  : "src/main/build"
      page : "target/pages"
    }
  })
  return
