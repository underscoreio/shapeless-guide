'use strict'

_      = require 'underscore'
pandoc = require 'pandoc-filter'
crypto = require 'crypto'

# String helpers --------------------------------

# arrayOf(node) -> string
textOf = (body) =>
  ans = ""
  for item in body
    switch item.t
      when "Str"   then ans += item.c
      when "Space" then ans += " "
  ans

# string integer -> string
numberedTitle = (title, number = 1) ->
  if number == 1 then title else "#{title} Part #{number}"

# string string -> string
stripPrefix = (title, prefix) ->
  if title.indexOf(prefix) == 0
    title.substring(prefix.length).trim()
  else
    title

# string -> string
labelCounter = 0
label = (prefix, title) ->
  # prefix + title.replace(/[^a-zA-z0-9 ]+/g, "").replace(/[ ]+/g, "-").toLowerCase()
  labelCounter = labelCounter + 1
  prefix + crypto.createHash('md5').update(title + "-" + labelCounter).digest("hex")

# Data types ------------------------------------

class Heading
  constructor: (@label, @title) ->
    # Do nothing

class Solution
  constructor: (@exerciseLabel, @solutionLabel, @exerciseTitle, @solutionTitle, @body) ->
    # Do nothing

createFilter = ({ chapterHeading, solutionHeading, linkToSolution, linkToExercise }) ->
  # Accumulators ----------------------------------

  # arrayOf(or(Heading, Solution))
  #
  # A list of chapter (level 1) headings and solutions:
  solutionAccum = []

  # or(Heading, null)
  #
  # The last heading (any level) we passed.
  # We record this because exercise titles are rendered using headings:
  chapterAccum = null
  headingAccum = null

  # integer
  #
  # The number of solutions we've passed since the last heading.
  # We record this because some exercises have multiple solutions:
  chapterCounter = 0 # index of solution since last chapter heading
  headingCounter = 0 # index of solution since last heading

  # Tree walkin' ----------------------------------

  return (type, value, format, meta) ->
    switch type
      when 'Link'
        [ attrs, body, [ href, unused ] ] = value

        # console.error("LINK #{JSON.stringify(href)} | #{JSON.stringify(unused)} | #{textOf(body)}")

        return # don't rewrite the document here
      when 'Header'
        [ level, [ident, classes, kvs], body ] = value

        # console.error("HEAD#{level} #{JSON.stringify(ident)} | #{textOf(body)}")

        # Record the last title we passed so we can name and number exercises.
        # Some exercises have multiple solutions, so reset that counter too.
        headingAccum = new Heading(ident, textOf(body))
        headingCounter = 0

        # We keep a record of the last chapter heading.
        # As soon as we see a solution in this chapter,
        # we add the chapter heading as a subheading in the solutions chapter:
        if level == 1
          chapterAccum = headingAccum
          chapterCounter = 0

        return # don't rewrite the document here
      when 'Div'
        [ [ident, classes, kvs], body ] = value
        if classes?[0] == "solution"
          chapterCounter = chapterCounter + 1
          headingCounter = headingCounter + 1

          # If this is the first solution this chapter,
          # push the chapter heading on the list of items to
          # render in the solutions chapter:
          if chapterCounter == 1 then solutionAccum.push(chapterAccum)

          # Titles of the exercise and the solution:
          exerciseTitle = stripPrefix(headingAccum.title, "Exercise:")
          solutionTitle = "Solution to: " + numberedTitle(exerciseTitle, headingCounter)

          # Anchor labels for the exercise and the solution:
          exerciseLabel = headingAccum.label
          solutionLabel = label("solution:", solutionTitle)

          solution = new Solution(exerciseLabel, solutionLabel, exerciseTitle, solutionTitle, body)

          solutionAccum.push(solution)

          linkToSolution(solution)
        else if classes?[0] == "solutions"
          nodes = []
          for item in solutionAccum
            if item instanceof Heading
              # console.error("CHAPTER #{item.title}")

              nodes = nodes.concat [
                chapterHeading(item)
              ]
            else if item instanceof Solution
              # console.error("SOLUTION #{item.exerciseTitle} | #{item.solutionTitle} | #{item.exerciseLabel} | #{item.solutionLabel}")

              nodes = nodes.concat [
                solutionHeading(item)
                item.body...
                linkToExercise(item)
              ]
          return nodes

module.exports = {
  createFilter
}
