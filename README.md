# The Type Astronaut's Guide to Shapeless (Working Title)

Content for my Scala World 2016 workshop on [shapeless][shapeless].
This is a very early release of this material.
The title, repo location, and build system are likely to change.

Copyright 2016 Dave Gurnell.
Text and diagrams licensed [CC-BY-SA 3.0][text-license].
Code samples licensed [Apache 2.0][code-license]

## Reading the Book

An up-to-date PDF should can be found in [dist/shapeless-guide.pdf][pdf].

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

## Related Material

The slides from my Scala World workshop can be found [here][slides]
and the accompanying live-coding examples can be found [here][code].
Check the `solutions` branch for complete versions of the example code.

## Acknowledgements

Thanks to these fine people for their contributions:

- [ErunamoJAZZ](https://github.com/ErunamoJAZZ)
- [ronanM](https://github.com/ronanM)
- [Yoshimura Yuu](https://github.com/y-yu)

[text-license]: https://creativecommons.org/licenses/by-sa/3.0/
[code-license]: http://www.apache.org/licenses/LICENSE-2.0
[shapeless]: https://github.com/milessabin/shapeless
[pdf]: https://github.com/underscoreio/shapeless-guide/blob/develop/dist/shapeless-guide.pdf
[slides]: https://github.com/davegurnell/shapeless-guide-slides
[code]: https://github.com/underscoreio/shapeless-guide-code
