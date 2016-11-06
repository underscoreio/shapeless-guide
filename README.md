# The Type Astronaut's Guide to Shapeless

Copyright 2016 Dave Gurnell.
Text and diagrams licensed [CC-BY-SA 3.0][text-license].
Code samples licensed [Apache 2.0][code-license]

## Reading the Book

An up-to-date PDF can be found in [dist/shapeless-guide.pdf][pdf].

## Related Material

Accompanying code samples can be found here:<br>
https://github.com/underscoreio/shapeless-guide-code

Check the `solutions` branch for complete versions of each example.

## Building the Book

Install Docker and use `go.sh` to boot an instance
with all the right dependencies:

~~~
bash$ ./go.sh
~~~

Then use `sbt` to build the book:

~~~
sbt pdf
~~~

## Acknowledgements

Thanks to Miles Sabin, Richard Dallaway, Noel Welsh, Travis Brown,
and our [fellow space-farers on Github][contributors]
for their invaluable help and feedback.

[text-license]: https://creativecommons.org/licenses/by-sa/3.0/
[code-license]: http://www.apache.org/licenses/LICENSE-2.0
[shapeless]: https://github.com/milessabin/shapeless
[pdf]: https://github.com/underscoreio/shapeless-guide/blob/develop/dist/shapeless-guide.pdf
[slides]: https://github.com/davegurnell/shapeless-guide-slides
[code]: https://github.com/underscoreio/shapeless-guide-code
[contributors]: https://github.com/underscoreio/shapeless-guide/graphs/contributors
