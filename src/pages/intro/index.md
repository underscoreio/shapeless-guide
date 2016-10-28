# Introduction

This book is a guide to using [shapeless][link-shapeless],
a library for *generic programming* in Scala.
We assume shapeless 2.3.2 and either
Lightbend Scala 2.11.9 or Typelevel Scala 2.11.8.

Shapeless is large library,
so rather than cover everything it has to offer,
we will concentrate on a few compelling use cases
and use them to build a picture of the tools and patterns available.

Before we start, let's talk about what generic programming is
and why shapeless is so exciting to Scala developers.

<div class="callout callout-info">
*Source code for examples*

We've placed source code for
many of the examples in this guide
in an accompanying Github repo:

`https://github.com/davegurnell/shapeless-guide-code`

The `exercises` branch contains
skeleton Scala files with `TODOs` to fill in,
and the `solutions` branch contains
completed implementations.
</div>
