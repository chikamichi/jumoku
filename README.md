![Texte alternatif](http://img547.imageshack.us/img547/2932/logoJumoku.png "Jumoku logo")

**Build and manipulate tree structures in Ruby.**

## Synopsis

Jumoku provides you with tree structures and related tools to perform manipulation and computation the easy way. Trees are a subset of graphs, which are used in a whole slew of computer science and mathematical problems: network modelization, datasets storage, scientific computation, load balancing, games and AI designs, … Trees are frequently used to mimic hierarchal structures such as filesystems, or modelize decisionnal patterns, for instance.

Jumoku is built upon [Graphy](http://github.com/chikamichi/graphy "Graphy on Github"), a ruby-powered Graph Theory library, and aims at being a fully-fledged, pithy solution for tree-like structures managment. See below for additionnal information about graphs, trees, arborescences, why they're different and how to make good use of them.

## A few words about *trees*

A Tree is a graph subject to three basic constraints: nodes are all connected, they must not form any loop, and the branches binding nodes have no preferential direction. A tree is not compelled to have a root node and leaves as you may think *prima facie*. Trees with such features are called arborescences and Jumoku has support for them, too.

Jumoku (*currently under early development stage*) provides you with the following structures:

* RawTree: a tree-graph with only basic features
* **Tree**: a tree-graph with extended features built upon RawTree. That's what you'd want to use as a basic tree structure
* AVLTree (*not yet*)
* RedBlackTree (*not yet*)
* **Arborescence** (*not yet*): the structure everybody thinks of when asked about "trees", with a root, internal nodes and leaves

You can also extend those structures with hybrid behaviors (not Graph Theory compliant but may be useful):

* Directed (*not yet*): relax the *undirected* constraint
* Loopy (*not yet*): relax the *acyclic* constraint
* Atomic (*not yet*): relax the *connected* constraint

## Basic usage

To create an instance of a tree, you may use either inheritance or mixins.

### Inheritance or direct initialization

``` ruby
class MyTree < Jumoku::Tree; end
tree = MyTree.new

# or even simpler:
tree = Jumoku::Tree.new
```

### Mixing-in a "builder" module

``` ruby
class MyTree
  include Jumoku::RawTreeBuilder
end
tree = MyTree.new
```

The RawTree class is actually implemented this way.

### What you get

`tree` is now a Tree object, shipping with some default options:

* it is a valid tree *per se* (an undirected, acyclic, connected graph)
* Jumoku API's methods will ensure it remains so as you manipulate it
* it has no constraint on the number of branches per node (its branching number)

## Install, first steps and bootstraping

In order to play with Jumoku, you must:

``` bash
gem install jumoku
```

Now you can play in IRB:

``` bash
$ irb
ruby-1.9.1-p378 > require 'jumoku'
=> true
ruby-1.9.1-p378 > include Jumoku # so you won't have to prefix everything with "Jumoku::"
=> Object
ruby-1.9.1-p378 > t = Tree.new
=> #<Jumoku::Tree:0x000000020d5ac8 @vertex_dict={}, @vertex_labels={}, @edge_labels={}, @allow_loops=false, @parallel_edges=false, @edgelist_class=Set>
ruby-1.9.1-p378 > t.methods
=> # lot of stuff hopefully :)
```

A good way to get you started is by [reading the doc online](http://rdoc.info/projects/chikamichi/jumoku "Jumoku on rdoc.info"). You can locally generate the doc with any of the following commands (you'll need to have the `yard` gem installed):

``` bash
rake yard
yardoc
```

Be sure to take a look at the tests in `spec/` as well, as they document the public API extensively.

## What about graphs?

Trees are just simple graphs, with specific constraints on edges (branches) and vertices (nodes). In graph theory, a tree is defined as a graph which is undirected, acyclic and connected. A forest is a disjoint union of trees. Let's review those constraints:

* undirected: the branches of a tree have no direction and you can flow either from root toward leaves or reversily;
* acyclic: a cycle is defined as a path such that the starting node and the ending node are the same. Such paths are forbidden in a tree;
* connected: a tree is such that pair of distinct nodes can be connected through some path (but *not* a cycle).

This is quite restrictive, but not *that* restrictive. Instinctively, a tree structure would rather be described as an arborescence, that is a collection of nodes with a root node and some leaves (ending nodes), that is with a general direction (top-down). That is what you would use to use to modelize nested directories, for instance. From the mathematical point of view, legacy trees and arborescences have some little differencies (the latter are more constrained). Jumoku provides both structures.

Several ruby graph libraries exist, some pure-ruby, some as bindings (for instance, the popular igraph C backend). Jumoku makes use of the most up-to-date project among those available, [Graphy](http://github.com/chikamichi/graphy "Graphy on Github"). It's been forked to implement new features required by Jumoku, and is vendorized within this gem.

## License

See the LICENSE file.

## Contributing

Fork, hack, request!

