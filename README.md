**This library does not exist yet :)**

## Synopsis

Ruby lacks a solid, user-friendly tree library. The closest to this is [RubyTree](http://github.com/evolve75/RubyTree "RubyTree on Github"), a great piece of code, but it has some drawbacks:

* it's class-based, hence its difficult to "mixin" behavior
* the API is quite poorly designed (CamelCased, painful chained accessors, ...)
* unique names!
* it's not versatile enough

What would be great is a modular library providing us with tree behaviors (modules) and raw tree classes to inherit from if we ever need to.

One could easily fork RubyTree, but I'm under the impression starting from scratch means more fun and less bias!

## Examples

The simplest (raw) tree would ship with only generic methods to create and access/traverse nodes. These methods from `Evergreen::As::RawTree` would be shared by all other specialized tree kinds, so that this module would be Evergreen's base module.

    module MyTree
      include Evergreen::As::RawTree
      # you may extend as well, depending on your needs

      # (re)def things as you wish!

      # hint: this module will likely be included or extended in some class of your choice
    end

or:

    class MyTree
      include Evergreen::As::RawTree
    end

or:

    class MyTree < Evergreen::Tree::Raw
      # basically this RawTree class does the same as the module above
    end

You could also be more specific about your needs:

    myTree = Evergreen::Tree::Raw.new(:branching_number => 3) # 3 children per node at most

    myTree = Evergreen::Tree::Binary.new(:traversal => :post_order)

## Code organisation and APIs

Idea:

    Evergreen                                       lib/evergreen/

      Public API:
      ::As (modules)                                  as/
        ::RawTree                                       raw.rb  => Evergreen's core
        ::BinaryTree                                    binary/
        ::AVL                                             self_balanced.rb (avl, red-black, ... modules)
        ::RedBlackTree                                  
      ::Tree (classes)                                trees/
        ::Raw                                           raw.rb
        ::Binary                                        binaries.rb
        ::AVL
        ::RedBlack

      Private (implementation) API:
      ::Behaviors (modules, extended)                 behaviors/
        ::Search                                          
          ::Recursive                                     search_algo.rb
          ::Iterative                                     traversal_algo.rb
        ::Traversal                                       shape_algo.rb
          ::PreOrder                                      validations.rb
          ::InOrder
          ::PostOrder
          ::DepthFirst
          ::BreadthFirst
        ::Shape
          ::Balancing
          ::Branching
        ::Validations

A user may interact with two namespaces from the Evergreen public API:

* The `As` namespace gathers modules to mix-in via `include` or `extend`
* The `Tree` namespace gathers classes to inherit from. Those classes are "factories" which mixed-in a generic tree behavior from the `As` namespace.

A private API acts as the backbone of the public API, providing the actual implementation of each tree kinds. It is responsible for defining fine-grained behaviors to be branched to the generic `RawTree` module, so as to generate the specialized tree structures (binary, AVL, and so on). The `Behaviors` namespace gathers:

* search algorithms
* traversal algorithms
* shapers (handle branching number, reorder algorithms, ...)

So, for instance, the AVL tree made made available in the `Evergreen::As::AVL` module is actually designed the following way:

* including the generic `Evergreen::As::RawTree` module (which does *not* rely on any `Behaviors`)
* extending appropriate behaviors : `Behaviors::Shape::HeightBalanced` (at least).

## Maybe?

### Tools

Why not providing some `Evergreen::ComputationTools`?

### Tree on demand

If the user *wants to*, he can picks whatever additionnal behavior he wants:

    tree = Evergreen::Tree::AVL(:traversal => :post_order, :search => :iterative)

    # equivalent to:

    tree = Evergreen::Tree::Binary(:type => :avl, :traversal => :post_order, :search => :iterative)

    # or even:

    tree = Evergreen::Tree::Raw(:branching_number => 2, :height => :balanced, :traversal => :post_order, :search => :iterative)

By the way, not every behavior is available for a given tree kind, so a checking mechanism should be built-in (I think there's no need to be too restrictive here, we can trust the users to make consistent options choices and not feel appalled if Evergreen throws a `InconsistentBehaviorSetError` at their face; that is). To make it easy, we should have a simple way to freeze some behaviors attribute in specialized tree kinds. For instance, one should not be able to pass the `:branching_number` option to an `AVL` tree (either it raises an error or is ignored silently).

### What about graphs?

Trees are a particular kind of graphs, for which two of its vertices (nodes) are connected by exactly one path. Thus, maybe a general graph library would be useful, Evergreen being one particular subset.

What I'd like is something like this:

* **evergreen** => the dead-simple, ruby-powered tree lib. Provides you with only one implementation : "raw" tree (a general k-tree, that is free branching number, no nodes validation hooks, ... just the tree structure and accessors). Limited set of functionalities (no more complicated behaviors on-demand...). **Advantages**: simple. **Drawbacks**: simple.
* **evergreen-igraph** => kind of evergreen on steroïds. C-powered through the igraph ruby binding (need to install the C lib hence). Take all the great features from igraph and wrap them in a tree-oriented abstraction layer which make it easy to create specialized trees (self-balanced, AVL, neat traversal algorithms, and so on). **Advantages**: fully fledged. **Drawbacks**: none?

The two flavours would share the exact same API (evergreen-igraph's API being larger than evergreen's), so that switching between the two is a no-brainer.

