**This library does not exist yet :)**

## Synopsis

Ruby lacks a solid, user-friendly tree library. The closest to this is [RubyTree](http://github.com/evolve75/RubyTree "RubyTree on Github"), a great piece of code, but it has some drawbacks:

* the API is quite poorly designed
* hard-coded, bold conventions
* it's not versatile nor powerful enough!

What would be great is a modular library providing us with a dead-simple tree behavior we could tailor at will. Maybe a few specialized tree types (binaries…) if the kids yearn for it. One could easily fork RubyTree, but I'm under the impression starting from scratch means more fun and less bias!

## What about graphs?

Trees are just simple graphs, with specific constraints on edges (branches) and vertices (nodes). In graph theory, a tree is defined as a graph which is undirected, acyclic and connected. A forest is a disjoint union of trees. Let's review those constraints:

* undirected: the branches of a tree have no direction;
* acyclic: a cycle is defined as a path such that the starting node and the ending node are the same. Such paths are forbidden in a tree;
* connected: a tree is such that pair of distinct nodes can be connected through some path (not a cycle)

This is restrictive, but not *that* restrictive. Instinctively, a tree structure would rather be described as an arborescence, with a root and leave. That's what you'd want to use to modelize nested directories, for instance. Such a structure has additional constraints, and is derived from the more generalist tree*-as-in-graph-theory* structure under the name arborescence.

Therefore it seems to make sense to implements those structure using a graph backend. Fortunately, several ruby graph libraries exist (and even a ruby binding for the igraph C backend, but that'd be a burden to use). evergreen will make use of the most up-to-date project among those available, [Graphy](http://github.com/bruce/graphy "Graphy on Github"), using it as its backend. The library will hence be quite minimal: just another implementation of the `Graphy::Digraph` with appropriate constraints, packaged in a nice tree-oriented DSL (let's talk about nodes, leaves, children, branching and so on).

## Examples -- updated as the library evolves

What we really want is the simplest DSL possible.

For the moment, only one tree flavour is available: the raw tree, that is the simplest tree matching the standard graph theory definition.

To create an instance of such a tree, you may use inheritance/direct initialization:

    class MyTree < Evergreen::RawTree; end
    tree = Evergreen::RawTree.new

or mix-in a module "builder":

    class MyTree
      include Evergreen::RawTreeBuilder
    end
    tree = MyTree.new

Actually the RawTree class is nothing but the mixin code snippet above.

`tree` is now a raw tree object shipping with defaults options:

* no constraint for the branching number
* it is a undirected tree which operators ensure it remains acyclic and connected

What if we want to customize it a bit?

    # Not yet!
    tree = Evergreen::RawTree.new do |conf|
      conf.branching_number = 4     # at most 4 children per node
      conf.unique = true            # no duplicated node names allowed
      conf.direction = :bottom_up   # default is :top_down
    end

Then, we can think about implementing specialized trees (arborescence, binary trees, AVL, Red-Black... [and much more](http://en.wikipedia.org/wiki/List_of_graph_theory_topics#Trees)) and the appropriate set of search/traversal algorithms if needed.

## Install, first steps and notes

One issue with Graphy, as with any other graph lib outthere, is that it provides classes, not modules. I forked Graphy and switch from a class-based implementation to a module-based one (adding a class layer btw, so the public API remains the same). Hence both behaviors are provided: mixin and subclassing. evergreen can in turn provides the same flexibility.

In order to play with Evergreen, you must:

    git clone git://github.com/chikamichi/graphy.git
    cd graphy
    rake install
    cd..
    git clone git://github.com/chikamichi/evergreen.git
    cd evergreen
    rake install

Now you can play in IRB:

    $ irb
    ruby-1.9.1-p378 > require 'evergreen'
    => true 
    ruby-1.9.1-p378 > include Evergreen # so you won't have to prefix everything with Evergreen::
    => Object 
    ruby-1.9.1-p378 > t = RawTree.new
    => #<Evergreen::RawTree:0x000000020d5ac8 @vertex_dict={}, @vertex_labels={}, @edge_labels={}, @allow_loops=false, @parallel_edges=false, @edgelist_class=Set> 
    ruby-1.9.1-p378 > t.methods
    => # lot of stuff hopefully :)

Best way to start: read the doc. You can generate the YARDoc with both commands (need to install the `yard` gem if you have not yet):

    rake yard
    yardoc

Take a look at the tests in `spec/` as well.

