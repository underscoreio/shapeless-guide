# The Type Astronaut's Guide to Shapeless

Copyright 2016 Dave Gurnell.
Text and diagrams licensed [CC-BY-SA 3.0][text-license].
Code samples licensed [Apache 2.0][code-license]

## Reading the Book

You have three options for grabbing the book:

- grab an up-to-date PDF from [dist/shapeless-guide.pdf][pdf] (free);
- download the book from [Underscore][underscore] (also free)
  and get notified of future updates by email;
- order a print copy from [Underscore][underscore].

## Related Material

Accompanying code samples can be found here:<br>
https://github.com/underscoreio/shapeless-guide-code

Check the `solutions` branch for complete versions of each example.

## Building the eBook

Install Docker and use `go.sh` to boot an instance
with most of the right dependencies:

~~~
bash$ ./go.sh
~~~

Then run `npm install` to install the remaining dependencies:

~~~
npm install
~~~

And finally use `sbt` to build the book:

~~~
sbt pdf
~~~

## Building a printable book

To build a black and white,
print-ready version of the book,
edit `src/meta/pdf.yaml` and set
`blackandwhiteprintable` to `true`.
Then run `sbt pdf` as above.

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
[underscore]: https://underscore.io/books/shapeless-guide
[lulu]: http://www.lulu.com/shop/dave-gurnell/the-type-astronauts-guide-to-shapeless/paperback/product-22992219.html
