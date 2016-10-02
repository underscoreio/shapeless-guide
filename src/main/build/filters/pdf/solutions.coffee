#!/usr/bin/env coffee

solutions = require '../common/solutions'
listings  = require './listings'
pandoc    = require 'pandoc-filter'
stdin     = require 'get-stdin'

action = solutions.createFilter {
  chapterHeading:  (heading)  -> pandoc.Header(2, [ "", [], [] ], [ pandoc.Str(heading.title) ])
  solutionHeading: (solution) -> pandoc.Header(3, [ solution.solutionLabel, [], [] ], [ pandoc.Str(solution.solutionTitle) ])
  linkToSolution:  (solution) -> pandoc.Para([ pandoc.Link(["", [], []], [ pandoc.Str("See the solution")       ], [ "#" + solution.solutionLabel, "" ]) ])
  linkToExercise:  (solution) -> pandoc.Para([ pandoc.Link(["", [], []], [ pandoc.Str("Return to the exercise") ], [ "#" + solution.exerciseLabel, "" ]) ])
}

stdin((json) ->
  data = JSON.parse(json);
  format = if process.argv.length > 2 then process.argv[2] else ''
  json = pandoc.filter(data, action, format);
  output = pandoc.filter(json, listings.action, format)
  process.stdout.write(JSON.stringify(output))
)

