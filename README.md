# The Type Astronaut's Guide to Shapeless (Working Title)

Content for my Scala World 2016 workshop on [shapeless][shapeless].
This is a very early release of this material.
The title, repo location, and build system are likely to change.

Copyright 2016 Dave Gurnell. Licensed [CC-BY-SA 3.0][license].

## Getting Started

Install Docker and use `go.sh` to boot an instance
with all the right dependencies:

~~~
bash$ ./go.sh
~~~

Then use `sbt` to build the book:

~~~
sbt pdf
sbt html
sbt epub
~~~

[license]: https://creativecommons.org/licenses/by-sa/3.0/
[shapeless]: https://github.com/milessabin/shapeless
