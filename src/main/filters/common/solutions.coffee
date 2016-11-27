'use strict'

_        = require 'underscore'
pandoc   = require 'pandoc-filter'
crypto   = require 'crypto'
metadata = require './metadata'

# String helpers --------------------------------

# arrayOf(node) -> string
textOf = (body) =>
  ans = ""
  for item in body
    switch item.t
      when "Str"    then ans += item.c
      when "Space"  then ans += " "
      when "Emph"   then ans += textOf(item.c)
      when "Strong" then ans += textOf(item.c)
      when "Span"   then ans += textOf(item.c)
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

# Node helpers ----------------------------------

solutionsHeading = (text, level) -> 
  pandoc.Header(level, [ "solutions", [], [] ], [ pandoc.Str(text) ])

chapterHeading = (heading, template, level) -> 
  pandoc.Header(level, [ "", [], [] ], [ pandoc.Str(template.replace("$title", heading.title)) ])

solutionHeading = (solution, template, level) ->
  pandoc.Header(level, [ solution.solutionLabel, [], [] ], [ 
    pandoc.Str(
      template.replace(
        "$title"
        solution.exerciseTitle
      ).replace(
        "$part"
        if solution.exerciseNumber > 1 then "Part #{solution.exerciseNumber}" else ""
      )
    )
  ])

linkToSolution = (solution) ->
  pandoc.Para([ pandoc.Link(["", [], []], [ pandoc.Str("See the solution")       ], [ "#" + solution.solutionLabel, "" ]) ])

linkToExercise = (solution) ->
  pandoc.Para([ pandoc.Link(["", [], []], [ pandoc.Str("Return to the exercise") ], [ "#" + solution.exerciseLabel, "" ]) ])

# Data types ------------------------------------

class Heading
  constructor: (@label, @title) ->
    # Do nothing

class Solution
  constructor: (@exerciseLabel, @solutionLabel, @exerciseTitle, @exerciseNumber, @body) ->
    # Do nothing

createFilter = ->
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
  chapterCounter  = 0 # index of solution since last chapter heading
  exerciseCounter = 0 # index of solution since last heading

  # Tree walkin' ----------------------------------

  return (type, value, format, meta) ->
    switch type
      when 'Link'
        [ attrs, body, [ href, unused ] ] = value

        
        return # don't rewrite the document here
      when 'Header'
        [ level, [ident, classes, kvs], body ] = value

        
        # Record the last title we passed so we can name and number exercises.
        # Some exercises have multiple solutions, so reset that counter too.
        headingAccum    = new Heading(ident, textOf(body))
        exerciseCounter = 0

        # We keep a record of the last chapter heading.
        # As soon as we see a solution in this chapter,
        # we add the chapter heading as a subheading in the solutions chapter:
        if level == 1
          chapterAccum   = headingAccum
          chapterCounter = 0

        return # don't rewrite the document here
      when 'Div'
        [ [ident, classes, kvs], body ] = value
        if classes?[0] == "solution"
          chapterCounter  = chapterCounter  + 1
          exerciseCounter = exerciseCounter + 1

          # If this is the first solution this chapter,
          # push the chapter heading on the list of items to
          # render in the solutions chapter:
          if chapterCounter == 1 then solutionAccum.push(chapterAccum)

          # Titles of the exercise and the solution:
          exerciseTitle = stripPrefix(headingAccum.title, "Exercise:")
          
          # Anchor labels for the exercise and the solution:
          exerciseLabel = headingAccum.label
          solutionLabel = label("solution:", exerciseTitle)

          solution = new Solution(exerciseLabel, solutionLabel, exerciseTitle, exerciseCounter, body)

          solutionAccum.push(solution)

          linkToSolution(solution)
        else if classes?[0] == "solutions"
          solutionsHeadingText    = metadata.getString(meta, ['solutions', 'headingText'])             ? undefined
          solutionsHeadingLevel   = metadata.getInt(meta,    ['solutions', 'headingLevel'])            ? 1
          chapterHeadingTemplate  = metadata.getString(meta, ['solutions', 'chapterHeadingTemplate'])  ? "$title"
          chapterHeadingLevel     = metadata.getInt(meta,    ['solutions', 'chapterHeadingLevel'])     ? 2
          solutionHeadingTemplate = metadata.getString(meta, ['solutions', 'solutionHeadingTemplate']) ? "Solution to: $title $part"
          solutionHeadingLevel    = metadata.getInt(meta,    ['solutions', 'solutionHeadingLevel'])    ? 3
          
          # console.error(new Error("" + solutionsHeadingText))
          # console.error(new Error("" + solutionsHeadingLevel))
          # console.error(new Error("" + chapterHeadingTemplate))
          # console.error(new Error("" + chapterHeadingLevel))
          # console.error(new Error("" + solutionHeadingTemplate))
          # console.error(new Error("" + solutionHeadingLevel))

          nodes = if solutionsHeadingText? then [ solutionsHeading(solutionsHeadingText, solutionsHeadingLevel) ] else []

          for item in solutionAccum
            if item instanceof Heading
              nodes = nodes.concat [
                chapterHeading(item, chapterHeadingTemplate, chapterHeadingLevel)
              ]
            else if item instanceof Solution
              nodes = nodes.concat [
                solutionHeading(item, solutionHeadingTemplate, solutionHeadingLevel)
                item.body...
                linkToExercise(item)
              ]

          return nodes

module.exports = {
  createFilter
}
