**This library does not exist yet :)**

## Synopsis

Ruby lacks a solid, user-friendly tree library. The closest to this is [RubyTree](http://github.com/evolve75/RubyTree "RubyTree on Github"), a great piece of code, but it has some drawbacks:

* the API is quite poorly designed
* hard-coded, bold conventions
* it's not versatile nor powerful enough!

What would be great is a modular library providing us with a dead-simple tree behavior we could tailor at will. Maybe a few specialized tree types (binaries…) if the kids yearn for it. One could easily fork RubyTree, but I'm under the impression starting from scratch means more fun and less bias!

## What about graphs?

Trees are just simple graphs, with specific constraints on edges (branches) and vertices (nodes/leaves) management. In graph theory, a tree is defined as a graph in which any two vertices (so-called nodes) are connected by exactly one simple path. In other words, any connected graph without cycles is a tree. A forest is a disjoint union of trees. Tree may or may not be directed, may or may not be rooted, have constraints on their branching number, etc. but fundamentally the sole requirement is that of the acyclic-connected rule.

Fortunately, several ruby graph libraries exist (and even a ruby binding for the igraph C backend, but that'd be a burden to use). evergreen will make use of the most up-to-date project among those available, [Graphy](http://github.com/bruce/graphy "Graphy on Github"), using it as its backend. The library will hence be quite minimal: just another implementation of the `Graphy::Digraph` with appropriate constraints, packaged in a nice tree-oriented DSL (let's talk about nodes, leaves, children, branching and so on). Really straightforward, not much work to achieve, alleviating pain of designing the whole package from scratch while gaining the ability to reuse high-performance traversal/search algorithms.

## Examples

What we really want is the simplest DSL possible. Either using inheritance/direct initialization:

    class MyTree < Evergreen::Tree; end
    tree = Evergreen::Tree.new

or mixing-in a module builder:

    class MyTree
      include Evergreen::TreeBuilder
    end
    tree = MyTree.new

`tree` is now a raw tree object shipping with defaults options:

* no constraint for the branching number
* nodes ain't need to be unique as far as their naming is concerned
* it is a directed tree, flowing from root to leaves

What if we want to customize it a bit?

    tree = Evergreen::Tree.new do |conf|
      conf.branching_number = 4     # at most 4 children per node
      conf.unique = true            # no duplicated node names allowed
      conf.direction = :bottom_up   # default is :top_down
    end

Then, we can think about implementing specialized trees (binaries, AVL, Red-Black... [and much more](http://en.wikipedia.org/wiki/List_of_graph_theory_topics#Trees)) and the appropriate set of search/traversal algorithms if needed.

## Notes

One issue with Graphy, as with any other graph lib outthere, is that it provides classes, not modules. I forked Graphy and switch from a class-based implementation to a module-based one (adding a class layer btw, so the public API remains the same). Hence both behaviors are provided: mixin and subclassing. evergreen can in turn provides the same flexibility.

