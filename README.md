**This library does not exist yet :)**

## Synopsis

Ruby lacks a solid, user-friendly tree library. The closest to this is [RubyTree](http://github.com/evolve75/RubyTree "RubyTree on Github"), a great piece of code, but it has some drawbacks:

* the API is quite poorly designed
* hard-coded, bold conventions
* it's not versatile nor powerful enough!

What would be great is a modular library providing us with a dead-simple tree behavior we could tailor at will. Maybe a few specialized tree types (binaries…) if the kids yearn for it. One could easily fork RubyTree, but I'm under the impression starting from scratch means more fun and less bias!

## What about graphs?

Trees are just simple graphs, with specific constraints on edges (branches) and vertices (nodes/leaves) management. The average tree has one constraint: its nodes must be connected by exactly one path.

Fortunately, a few ruby-powered graph libraries exist (and a ruby binding for the igraph C backend, but that'd be a burden). evergreen could make use of the most up-to-date project among those available, [Graphy](http://github.com/bruce/graphy "Graphy on Github"), as its backend. The library would hence be quite minimal: just another implementation of the `Graphy::Digraph` with appropriate constraints, packaged in a nice tree-oriented DSL (nodes, leaves, children, branches, and so on). *+*: Really straightforward, not much work to achieve, and fully-fledged.

## Examples

What we really want is the simplest DSL possible:

    tree = Evergreen.tree
    # tree is now a raw tree object shipping with defaults options:
    # - no constraint on the branching number
    # - nodes ain't need to be unique
    # - it is a directed tree, from root to leaves
    # It mimics a hierarchy.

What if we want to customize it a bit?

    tree = Evergreen.tree do |conf|
      conf.branching_number = 4     # at most 4 children per node
      conf.unique = true            # no duplicated node names allowed
      conf.direction = :bottom_up   # default is :top_down
    end

Then, we can think about implementing specialized tree (binaries, AVL, Red-Black...) and the appropriate set of search and traversal algorithms.

