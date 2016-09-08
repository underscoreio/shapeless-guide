#!/usr/bin/env coffee

solutions = require '../common/solutions'
pandoc    = require 'pandoc-filter'

pandoc.stdio(solutions.createFilter {
  chapterHeading:  (heading)  -> pandoc.Header(2, [ "", [], [] ], [ pandoc.Str(heading.title) ])
  solutionHeading: (solution) -> pandoc.Header(3, [ solution.solutionLabel, [], [] ], [ pandoc.Str(solution.solutionTitle) ])
  linkToSolution:  (solution) -> pandoc.Para([ pandoc.Link(["", [], []], [ pandoc.Str("See the solution")       ], [ "#" + solution.solutionLabel, "" ]) ])
  linkToExercise:  (solution) -> pandoc.Para([ pandoc.Link(["", [], []], [ pandoc.Str("Return to the exercise") ], [ "#" + solution.exerciseLabel, "" ]) ])
})
