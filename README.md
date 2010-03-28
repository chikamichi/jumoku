**This library does not exist yet :)**

## Synopsis

Ruby lacks a solid, user-friendly tree library. The closest to this is [RubyTree](http://github.com/evolve75/RubyTree "RubyTree on Github"), a great piece of code, but it has some drawbacks:

* it's class-based, hence its difficult to "mixin" behavior
* the API is quite poorly designed (CamelCased, painful chained accessors, ...)
* hard-coded choices
* it's not versatile enough

What would be great is a modular library providing us with tree behaviors (via modules) and raw tree classes to inherit from if we ever need to. One could easily fork RubyTree, but I'm under the impression starting from scratch means more fun and less bias!

### What about graphs?

Trees are merely simple graphs, with bold constraints on edges and vertices (nodes). The usual tree is quite restrictive: nodes must be connected by exactly one path.

Fortunately, a few ruby-powerd graph libraries exist, and event a ruby binding for the supe-fast igraph C backend. evergreen could make use of the most up-to-date project, [Graphy](http://github.com/bruce/graphy "Graphy on Github"), as its backend. The library would thus be quite straightforward: another implementation of the `Graphy::Digraph` with appropriate constraints, packaged as a nice tree-oriented DSL (must talk about nodes and children and branch and...) Really straightforward, not much work to achieve, and fully-fledged.

## Examples

What we really want is the simplest DSL possible:

    class MyTree
      include Evergreen::Tree
    end

    # MyTree is now a raw tree implementation shipping with defaults options:
    # - no constraint on the branching number
    # - nodes ain't need to be unique
    # - it is a directed tree, from root to leaves

What if we want to customize it a bit?

    class MyTree
      include Evergreen::Tree

      define_tree_params do |p|
        p.branching_number = 4 # at most 4 children per node
        p.unique = true
        p.direction = :bottom_up # default is :top_down
      end
    end

For convenience, evergreen would provide class implementations you can inherit from and tweak at instanciation:

    tree = Evergreen::Build::Tree.new

    tree = Evergreen::Build::Tree.new { |p| p.unique = true }

Then, we can think about implementing specialized tree (binaries, AVL, Red-Black...) and the appropriate set of search and traversal algorithms.

