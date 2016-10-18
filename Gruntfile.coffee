#global module:false

"use strict"

ebook = require 'underscore-ebook-template'

module.exports = (grunt) ->
  ebook(grunt, {
    dir: {
      # lib      : "src/build"
      page     : "target/pages"
      template : "src/template"
    }
  })
  return
