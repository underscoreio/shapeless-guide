# Working with types and implicits {#sec:type-level-programming}

In the last chapter we saw
one of the most compelling use cases for shapeless:
automatically deriving type class instances.
There are plenty of even more powerful examples coming later.
However, before we move on, we should take time
to discuss some theory we've skipped over
and establish a set of patterns for writing and debugging
type- and implicit-heavy code.
